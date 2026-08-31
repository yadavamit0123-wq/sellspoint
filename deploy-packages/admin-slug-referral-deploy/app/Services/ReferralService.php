<?php

namespace App\Services;

use App\Models\User;
use App\Models\ReferralIncome;
use App\Models\TransactionHistory;
use Illuminate\Support\Facades\DB;
use App\Models\Setting;

class ReferralService
{
    /** Purana Sells Point flow: sirf direct referrer (Level 1) ko pay karo. */
    protected static $levelIncome = [
        1 => 5,
    ];

    /**
     * Credit direct referrer only (Level 1 = ₹5 by default).
     *
     * @param User $newUser
     * @return void
     * @throws \Exception
     */
    public static function distributeReferralIncome(User $newUser)
    {
        if (empty($newUser->by_reffer_id)) {
            return;
        }

        $referrer = User::where('reffer_id', $newUser->by_reffer_id)->first();
        if (! $referrer) {
            return;
        }

        $levelIncome = self::resolveLevelIncome();
        $amount = (float) ($levelIncome[1] ?? 5);
        if ($amount <= 0) {
            return;
        }

        DB::beginTransaction();
        try {
            ReferralIncome::create([
                'user_id'      => $referrer->id,
                'from_user_id' => $newUser->id,
                'level'        => 1,
                'amount'       => $amount,
            ]);

            $referrer->wallet = ($referrer->wallet ?? 0) + $amount;
            $referrer->save();
            self::createTransaction($referrer->id, 'Refferal Amount Credit', $amount);

            DB::commit();
        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }

    protected static function resolveLevelIncome(): array
    {
        $setting = Setting::where('name', 'reffer_level_income')->first();
        if ($setting === null) {
            return self::$levelIncome;
        }

        $decoded = json_decode($setting->value, true);

        return is_array($decoded) ? $decoded : self::$levelIncome;
    }
    
    
    public static function createTransaction($userId,$title,$amount,$type = "credit",$status = "approoved"){
        
          TransactionHistory::create([
                    'status'      => $status,
                    'type' =>$type,
                    'amount'        => $amount,
                    'title'       => $title,
                    'user_id'       => $userId,
                ]);
                
    }
}
