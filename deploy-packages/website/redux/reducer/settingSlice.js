import { createSelector, createSlice } from "@reduxjs/toolkit";
import { store } from "../store";

const initialState = {
  data: null,
  lastFetch: null,
  loading: false,
  fcmToken: null,
};

export const settingsSlice = createSlice({
  name: "Settings",
  initialState,
  reducers: {
    settingsSucess: (settings, action) => {
      const { data } = action.payload;
      settings.data = data;
    },
    getToken: (settings, action) => {
      settings.fcmToken = action.payload.data;
    },
  },
});

export const { settingsSucess, getToken } = settingsSlice.actions;
export default settingsSlice.reducer;

// Action to store token
export const getFcmToken = (data) => {
  store.dispatch(getToken({ data }));
};

// Selectors
export const settingsData = createSelector(
  (state) => state.Settings,
  (settings) => settings.data?.data
);

export const Fcmtoken = createSelector(
  (state) => state.Settings,
  (settings) => settings?.fcmToken
);

export const getIsLandingPage = createSelector(
  (state) => state.Settings,
  (settings) => Number(settings?.data?.data?.show_landing_page)
);

export const getPlaceholderImage = createSelector(
  (state) => state.Settings,
  (settings) => settings?.data?.data?.placeholder_image
);

export const getCompanyName = createSelector(
  (state) => state.Settings,
  (settings) => settings?.data?.data?.company_name
);

export const getIsMaintenanceMode = createSelector(
  (state) => state.Settings,
  (settings) => Number(settings?.data?.data?.maintenance_mode) === 1
);

export const getIsFreAdListing = createSelector(
  (state) => state.Settings,
  (settings) => Number(settings?.data?.data?.free_ad_listing) === 1
);

export const getMinRange = createSelector(
  (state) => state.Settings,
  (settings) => Number(settings?.data?.data?.min_length) || 0
);

export const getMaxRange = createSelector(
  (state) => state.Settings,
  (settings) => Number(settings?.data?.data?.max_length) || 100
);

export const getOtpServiceProvider = createSelector(
  (state) => state.Settings,
  (settings) => settings?.data?.data?.otp_service_provider
);

export const getDefaultLatitude = createSelector(
  (state) => state.Settings,
  (settings) => Number(settings?.data?.data?.default_latitude)
);
export const getDefaultLongitude = createSelector(
  (state) => state.Settings,
  (settings) => Number(settings?.data?.data?.default_longitude)
);
export const getIsPaidApi = createSelector(
  (state) => state.Settings,
  (settings) => settings?.data?.data?.map_provider === "google_places"
);

export const getLanguages = createSelector(
  (state) => state.Settings,
  (settings) => settings?.data?.data?.languages
);

export const getDefaultLanguageCode = createSelector(
  (state) => state.Settings,
  (settings) => settings?.data?.data?.default_language?.toLowerCase()
);

export const getLanguageInfo = createSelector(
  [getLanguages, getDefaultLanguageCode],
  (languages, defaultLang) => ({
    supportedLangs: languages?.map(l => l.code.toLowerCase()) || [],
    defaultLangCode: defaultLang || 'en',
  })
);

export const getShowLandingPage = createSelector(
  (state) => state.Settings,
  (settings) => Number(settings?.data?.data?.show_landing_page) === 1
);

export const getCurrencyPosition = createSelector(
  (state) => state.Settings,
  (settings) => settings?.data?.data?.currency_symbol_position
);

export const getCurrencySymbol = createSelector(
  (state) => state.Settings,
  (settings) => settings?.data?.data?.currency_symbol
);


export const getCurrencyIsoCode = createSelector(
  (state) => state.Settings,
  (settings) => settings?.data?.data?.currency_iso_code
);

export const getAboutUs = createSelector(
  (state) => state.Settings,
  (settings) => settings?.data?.data?.about_us
);


export const getFaviconUrl = createSelector(
  (state) => state.Settings,
  (settings) => settings?.data?.data?.favicon_icon
);


export const getIsReferAndEarnEnabled = createSelector(
  (state) => state.Settings,
  (settings) => Number(settings?.data?.data?.refer_earn_enabled) === 1
);

export const getReferralSettings = createSelector(
  (state) => state.Settings,
  (settings) => ({
    refer_earn_enabled: Number(settings?.data?.data?.refer_earn_enabled) === 1,
    refer_max_points_to_use: Number(settings?.data?.data?.refer_max_points_to_use),
    refer_max_points_usage_percentage: Number(settings?.data?.data?.refer_max_points_usage_percentage),
    refer_min_points_to_use: Number(settings?.data?.data?.refer_min_points_to_use),
  })
);

export const getAdsenseSettings = createSelector(
  (state) => state.Settings,
  (settings) => ({
    adsense_enabled: Number(settings?.data?.data?.adsense_enabled) === 1,
    adsense_mode: settings?.data?.data?.adsense_mode,
    adsense_client_id: settings?.data?.data?.adsense_client_id,
    adsense_banner_slot_id: settings?.data?.data?.adsense_banner_slot_id,
    adsense_vertical_slot_id: settings?.data?.data?.adsense_vertical_slot_id,
    adsense_square_slot_id: settings?.data?.data?.adsense_square_slot_id,
  })
);

export const getGeminiAiEnabled = createSelector(
  (state) => state.Settings,
  (settings) => Number(settings?.data?.data?.gemini_ai_enabled) === 1
);

export const getHomeScreenSections = createSelector(
  (state) => state.Settings,
  (settings) => settings?.data?.data?.home_screen_sections ?? null
);

export const getMaxGalleryImages = createSelector(
  (state) => state.Settings,
  (settings) => Number(settings?.data?.data?.max_gallery_images)
);


export const getReelMaxSize = createSelector(
  (state) => state.Settings,
  (settings) => Number(settings?.data?.data?.reel_max_file_size_mb)
);

export const getReelMaxDuration = createSelector(
  (state) => state.Settings,
  (settings) => Number(settings?.data?.data?.reel_max_duration_sec)
);

export const getVideoMaxSize = createSelector(
  (state) => state.Settings,
  (settings) => Number(settings?.data?.data?.item_video_max_file_size_mb)
);


