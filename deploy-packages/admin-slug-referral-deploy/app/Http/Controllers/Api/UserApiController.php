<?php

namespace App\Http\Controllers\Api;

use App\Models\City;
use App\Models\Language;
use App\Models\Notifications;
use App\Models\Referral;
use App\Models\SellerRating;
use App\Models\User;
use App\Models\UserFcmToken;
use App\Services\CachingService;
use App\Services\FileService;
use App\Services\HelperService;
use App\Services\ResponseService;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;
use Throwable;

/**
 * @tags User
 */
class UserApiController extends BaseApiController
{
    /**
     * Get User Info
     */
    public function getUser(Request $request)
    {
        try {
            $auth = Auth::user();

            if (! $auth) {
                ResponseService::errorResponse(__('User not authenticated'));
            }

            if (! $auth->hasRole('User')) {
                ResponseService::errorResponse(__('Invalid User Role'));
            }
            $user = User::withCount([
                'followers as followers_count',
                'following as following_count'
            ])->find($auth->id);

            ResponseService::successResponse(__('User fetched successfully'), $user);
        } catch (Throwable $th) {
            ResponseService::logErrorResponse($th, 'API Controller -> GetUser');
            ResponseService::errorResponse();
        }
    }

    /**
     * Update Profile
     */
    public function updateProfile(Request $request)
    {
        try {
            DB::beginTransaction();
            $app_user = Auth::user();

            $rules = [
                'name' => 'nullable|string',
                'profile' => 'nullable|mimes:jpg,jpeg,png|max:7168',
                'email' => 'nullable|email|unique:users,email,' . $app_user->id,
                'mobile' => [
                    'nullable',
                    Rule::unique('users')->ignore($app_user->id)->where(function ($query) use ($request) {
                        return $query->where('country_code', '+' . $request->country_code);
                    }),
                ],
                'fcm_id' => 'nullable',
                'address' => 'nullable',
                'show_personal_details' => 'boolean',
                'country_code' => 'nullable|string',
                'region_code' => 'nullable|string',
            ];

            // Referral code can only be added once (on first profile update)
            if (! $app_user->used_referral_code) {
                $rules['referral_code'] = 'nullable|string|exists:users,referral_code';
            }

            $validator = Validator::make($request->all(), $rules);

            if ($validator->fails()) {
                ResponseService::validationError($validator->errors()->first());
            }

            // Allow specific fields to be updated in user data
            $allowedFields = ['name', 'mobile', 'address', 'show_personal_details', 'country_code', 'region_code'];
            if ($app_user->type !== 'google') {
                $allowedFields[] = 'email';
            }
            // Referral code can only be added once (on first profile update)
            if (!$app_user->used_referral_code) {
                $allowedFields[] = 'referral_code';
            }

            $data = $request->only($allowedFields);

            if ($request->hasFile('profile')) {
                $data['profile'] = FileService::compressAndReplace($request->file('profile'), 'profile', $app_user->getRawOriginal('profile'));
            }

            if (! empty($request->fcm_id)) {
                UserFcmToken::updateOrCreate(['fcm_token' => $request->fcm_id], ['user_id' => $app_user->id, 'created_at' => Carbon::now(), 'updated_at' => Carbon::now()]);
            }

            // Process referral code only if user hasn't used one before
            if (! $app_user->used_referral_code && ! empty($request->referral_code)) {
                $referrer = User::where('referral_code', strtoupper($request->referral_code))->first();
                
                if ($referrer) {
                    // Mark as used so it can't be changed again
                    $data['used_referral_code'] = true;
                }

                if ($request->filled('referral_code')) {
                    $referEarnEnabled = CachingService::getSystemSettings('refer_earn_enabled');
                    if ($referEarnEnabled == '1') {
                        $referrer = User::where('referral_code', $request->referral_code)->first();
                        if ($referrer && $referrer->id !== $app_user->id) {
                            $alreadyReferred = Referral::where('referred_id', $app_user->id)->exists();
                            if (!$alreadyReferred) {
                                Referral::create([
                                    'referrer_id' => $referrer->id,
                                    'referred_id' => $app_user->id,
                                    'is_rewarded' => false,
                                ]);
                            }
                        }
                    }
                }
            }

            $data['show_personal_details'] = $request->show_personal_details;
            if (! empty($data['name']) && $data['name'] !== $app_user->name) {
                $data['slug'] = HelperService::generateSellerProfileSlug(
                    $data['name'],
                    $app_user->id
                );
            }
            $app_user->update($data);
            $app_user->refresh();

            DB::commit();
            ResponseService::successResponse(__('Profile Updated Successfully'), $app_user);
        } catch (Throwable $th) {
            DB::rollBack();
            ResponseService::logErrorResponse($th, 'API Controller -> updateProfile');
            ResponseService::errorResponse();
        }
    }

    /**
     * Get Seller Details
     */
    public function getSeller(Request $request)
    {
        $request->validate([
            'id' => 'nullable|integer',
            'slug' => 'nullable|string',
        ]);

        if (! $request->id && ! $request->slug) {
            ResponseService::validationError(__('Either id or slug is required'));
        }

        try {
            $seller = $this->resolveSellerQuery($request)->first();

            if (! $seller) {
                ResponseService::errorResponse(__('Seller not found'));
            }

            $ratingQuery = SellerRating::where('seller_id', $seller->id)->with('buyer:id,name,profile');
            $totalOneRatings = $ratingQuery->clone()->where('ratings', 1)->count();
            $totalTwoRatings = $ratingQuery->clone()->where('ratings', 2)->count();
            $totalThreeRatings = $ratingQuery->clone()->where('ratings', 3)->count();
            $totalFourRatings = $ratingQuery->clone()->where('ratings', 4)->count();
            $totalFiveRatings = $ratingQuery->clone()->where('ratings', 5)->count();
            $ratings = $ratingQuery->clone()->paginate(10);
            $averageRating = $ratings->avg('ratings');

            $isFollowing = 0;
            if (Auth::check()) {
                $authUser = Auth::user();
                $isFollowing = $authUser->isFollowing($seller->id) ? 1 : 0;
            }

            $response = [
                'seller' => [
                    ...$seller->toArray(),
                    'average_rating' => $averageRating,
                    'is_following' => $isFollowing,
                ],
                'ratings' => $ratings,
                'ratings_count' => array(
                    1 => $totalOneRatings ?? 0,
                    2 => $totalTwoRatings ?? 0,
                    3 => $totalThreeRatings ?? 0,
                    4 => $totalFourRatings ?? 0,
                    5 => $totalFiveRatings ?? 0,
                ),
            ];

            ResponseService::successResponse(__('Seller Details Fetched Successfully'), $response);
        } catch (Throwable $th) {
            ResponseService::logErrorResponse($th, 'API Controller -> getSeller');
            ResponseService::errorResponse();
        }
    }

    /**
     * Get Seller Slugs
     */
    public function getSellerSlug(Request $request)
    {
        try {
            $sellers = User::select('id', 'slug')
                ->whereNull('deleted_at')
                ->whereNotNull('slug')
                ->paginate(500);

            if ($sellers->isEmpty()) {
                return ResponseService::errorResponse(__('No active seller found.'));
            }

            return ResponseService::successResponse(__('Active Seller fetched successfully.'), $sellers);
        } catch (Throwable $th) {
            ResponseService::logErrorResponse($th, 'API Controller -> getSellerSlug');
            ResponseService::errorResponse();
        }
    }

    protected function resolveSellerQuery(Request $request)
    {
        $query = User::withCount([
            'followers as followers_count',
            'following as following_count',
        ]);

        if ($request->filled('slug')) {
            $slug = $request->slug;
            $query->where(function ($q) use ($slug) {
                $q->where('slug', $slug);
                $parsedId = HelperService::resolveSellerIdFromSlug($slug);
                if ($parsedId) {
                    $q->orWhere('id', $parsedId);
                }
            });
        } else {
            $query->where('id', $request->id);
        }

        return $query;
    }

    /**
     * Get Notification List
     */
    public function getNotificationList(Request $request)
    {
        try {
            $user = Auth::user();
            $authId = $user->id;
            $userCreatedAt = $user->created_at;
            $id = $request->id;

            $query = Notifications::with(['item.area', 'item.translations'])
                ->where(function ($q) use ($authId, $userCreatedAt) {
                    $q->whereRaw('FIND_IN_SET(?, user_id)', [$authId])
                        ->orWhere(function ($sq) use ($userCreatedAt) {
                            $sq->where('send_to', 'all')
                                ->where('created_at', '>=', $userCreatedAt);
                        });
                });

            if (! empty($id)) {
                $notifications = $query->where('id', $id)->first();
                if (! $notifications) {
                    return ResponseService::successResponse(__('Notification not found'), null);
                }
                $notificationCollection = collect([$notifications]);
            } else {
                $notifications = $query->orderBy('id', 'DESC')->paginate();
                $notificationCollection = $notifications->getCollection();
            }

            $currentLanguage = app()->getLocale();
            $currentLangId = Language::where('code', $currentLanguage)->value('id');

            foreach ($notificationCollection as $notification) {
                $item = $notification->item;
                if ($item) {
                    $city = City::with(['translations', 'state', 'country'])
                        ->where('name', $item->city)
                        ->whereHas('state', fn($q) => $q->where('name', $item->state))
                        ->first();

                    $translatedArea = $item->area->translated_name ?? '';
                    $translatedCity = $city?->translated_name ?? $item->city;
                    $translatedState = $city?->state?->translated_name ?? $item->state;
                    $translatedCountry = $city?->country?->translated_name ?? $item->country;

                    $item->translated_address = (! empty($translatedArea) ? $translatedArea . ', ' : '') .
                        $translatedCity . ', ' . $translatedState . ', ' . $translatedCountry;

                    if ($currentLanguage && $item->relationLoaded('translations')) {
                        $langTranslations = $item->translations->where('language_id', $currentLangId);
                        $tName = $langTranslations->where('key', 'name')->first();
                        $tDesc = $langTranslations->where('key', 'description')->first();
                        $tAddr = $langTranslations->where('key', 'address')->first();
                        if ($tName) $item->name = $tName->value;
                        if ($tDesc) $item->description = $tDesc->value;
                        if ($tAddr) $item->address = $tAddr->value;
                    }

                    $item->translated_area = $translatedArea;
                    $item->translated_city = $translatedCity;
                    $item->translated_state = $translatedState;
                    $item->translated_country = $translatedCountry;
                }
            }

            return ResponseService::successResponse(__('Notification fetched successfully'), $notifications);
        } catch (Throwable $th) {
            ResponseService::logErrorResponse($th, 'API Controller -> getNotificationList');

            return ResponseService::errorResponse();
        }
    }
}
