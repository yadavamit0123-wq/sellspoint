<?php

namespace App\Console\Commands;

use App\Models\Country;
use App\Models\Currency;
use Cerbero\JsonParser\JsonParser;
use Illuminate\Console\Command;
use Throwable;

class ImportCurrenciesFromWorld extends Command
{
    protected $signature = 'sellspoint:import-currencies {--force : Update existing currency rows}';

    protected $description = 'Import currencies for all countries in the database from resources/world.json';

    public function handle(): int
    {
        $countries = Country::pluck('id')->all();
        if (empty($countries)) {
            $this->error('No countries found. Import countries first from Admin → Countries.');

            return self::FAILURE;
        }

        $countryLookup = array_fill_keys($countries, true);
        $force = (bool) $this->option('force');
        $created = 0;
        $skipped = 0;
        $updated = 0;

        try {
            foreach (JsonParser::parse(resource_path('world.json')) as $country) {
                if (empty($countryLookup[$country['id'] ?? null])) {
                    continue;
                }

                $isoCode = strtoupper((string) ($country['currency'] ?? ''));
                if ($isoCode === '') {
                    $skipped++;
                    continue;
                }

                $payload = [
                    'iso_code' => $isoCode,
                    'name' => (string) ($country['currency_name'] ?? $isoCode),
                    'symbol' => (string) ($country['currency_symbol'] ?? $isoCode),
                    'symbol_position' => 'left',
                    'country_id' => $country['id'],
                ];

                $existing = Currency::where('country_id', $country['id'])->first();
                if ($existing) {
                    if ($force) {
                        $existing->update($payload);
                        $updated++;
                    } else {
                        $skipped++;
                    }
                    continue;
                }

                Currency::create($payload);
                $created++;
            }
        } catch (Throwable $e) {
            $this->error($e->getMessage());

            return self::FAILURE;
        }

        $this->info("Currencies imported. Created: {$created}, Updated: {$updated}, Skipped: {$skipped}.");

        return self::SUCCESS;
    }
}
