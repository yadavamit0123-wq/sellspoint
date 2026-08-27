<?php

namespace App\Console\Commands;

use App\Data\WorldLanguages;
use App\Models\Language;
use App\Services\CachingService;
use App\Services\HelperService;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\File;
use Throwable;

class ImportWorldLanguages extends Command
{
    protected $signature = 'sellspoint:import-languages {--force : Recreate JSON files for existing languages}';

    protected $description = 'Bulk import major world languages (copies English JSON templates)';

    public function handle(): int
    {
        $langPath = resource_path('lang');
        $panelTemplate = $langPath . '/en.json';
        $appTemplate = $langPath . '/en_app.json';
        $webTemplate = $langPath . '/en_web.json';

        foreach ([$panelTemplate, $appTemplate, $webTemplate] as $template) {
            if (! File::exists($template)) {
                $this->error("Missing template file: {$template}");

                return self::FAILURE;
            }
        }

        $force = (bool) $this->option('force');
        $created = 0;
        $skipped = 0;

        try {
            foreach (WorldLanguages::all() as $language) {
                $code = $language['code'];
                if (Language::where('code', $code)->exists()) {
                    if (! $force) {
                        $skipped++;
                        continue;
                    }
                }

                $panelFile = "{$code}.json";
                $appFile = "{$code}_app.json";
                $webFile = "{$code}_web.json";

                File::copy($panelTemplate, "{$langPath}/{$panelFile}");
                File::copy($appTemplate, "{$langPath}/{$appFile}");
                File::copy($webTemplate, "{$langPath}/{$webFile}");

                Language::updateOrCreate(
                    ['code' => $code],
                    [
                        'name' => $language['name'],
                        'name_in_english' => $language['name_in_english'],
                        'country_code' => $language['country_code'],
                        'rtl' => $language['rtl'],
                        'panel_file' => $panelFile,
                        'app_file' => $appFile,
                        'web_file' => $webFile,
                        'image' => 'language/en.svg',
                    ]
                );

                $created++;
            }

            CachingService::removeCache(config('constants.CACHE.LANGUAGE'));
            HelperService::revalidateLanguageCodes();
        } catch (Throwable $e) {
            $this->error($e->getMessage());

            return self::FAILURE;
        }

        $this->info("Languages imported. Created/Updated: {$created}, Skipped: {$skipped}.");

        return self::SUCCESS;
    }
}
