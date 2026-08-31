<?php

use App\Models\User;
use App\Services\HelperService;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            if (! Schema::hasColumn('users', 'slug')) {
                $table->string('slug')->nullable()->unique()->after('name');
            }
        });

        User::withTrashed()->orderBy('id')->chunk(500, function ($users) {
            foreach ($users as $user) {
                if (! empty($user->slug)) {
                    continue;
                }
                User::withTrashed()->where('id', $user->id)->update([
                    'slug' => HelperService::generateSellerProfileSlug($user->name, $user->id),
                ]);
            }
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            if (Schema::hasColumn('users', 'slug')) {
                $table->dropColumn('slug');
            }
        });
    }
};
