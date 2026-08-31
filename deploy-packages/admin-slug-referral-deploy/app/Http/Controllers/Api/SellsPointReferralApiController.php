<?php

namespace App\Http\Controllers\Api;

use App\Models\ReferralIncome;
use App\Models\TransactionHistory;
use App\Models\User;
use App\Services\ReferralService;
use App\Services\ResponseService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Throwable;

/**
 * Sells Point custom referral / wallet API (preserved from legacy ApiController).
 */
class SellsPointReferralApiController extends BaseApiController
{
    public function checkReffercode(string $reffercode)
    {
        $user = User::where('reffer_id', $reffercode)->first();
        if (! $user) {
            ResponseService::errorResponse('Invalid Reffer code', ['applied' => false]);
        }
        ResponseService::successResponse('Reffer code Applied', [
            'name' => $user->name,
            'applied' => true,
        ]);
    }

    public function applyReffer(Request $request)
    {
        try {
            $user = User::where('id', $request->user_id)->first();
            if (! $user) {
                ResponseService::errorResponse('User not found');
            }

            if ($user->by_reffer_id) {
                ResponseService::errorResponse('User Already Applied!');
            }

            $code = trim($request->reffer_code ?? '');
            if ($code === '') {
                ResponseService::errorResponse('Invalid Reffer code');
            }

            $referrer = User::where('reffer_id', $code)->first();
            if (! $referrer) {
                ResponseService::errorResponse('Invalid Reffer code');
            }

            if ($referrer->id === $user->id) {
                ResponseService::errorResponse('You cannot use your own referral code');
            }

            $user->by_reffer_id = $code;
            $user->save();
            ReferralService::distributeReferralIncome($user);
            ResponseService::successResponse('Successfully Applied!');
        } catch (Throwable $th) {
            ResponseService::logErrorResponse($th, 'SellsPointReferralApiController -> applyReffer');
            ResponseService::errorResponse();
        }
    }

    public function refferalHistory(Request $request)
    {
        $user = Auth::user();
        $transaction = ReferralIncome::with('user')->where('user_id', $user->id)->get();
        ResponseService::successResponse('Data Fetched Successfully', $transaction);
    }

    public function transactionHistory(Request $request)
    {
        $user = Auth::user();
        $transaction = TransactionHistory::where('user_id', $user->id)->get();
        ResponseService::successResponse('Data Fetched Successfully', $transaction);
    }
}
