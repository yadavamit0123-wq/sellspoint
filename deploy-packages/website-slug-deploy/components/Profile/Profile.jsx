"use client";
import { getDefaultCountryCode, t } from "@/utils";
import { Label } from "../ui/label";
import { Input } from "../ui/input";
import { useEffect, useState } from "react";
import { useSelector } from "react-redux";
import { decreaseFollowing, loadUpdateUserData, userSignUpData } from "@/redux/reducer/authSlice";
import { Switch } from "../ui/switch";
import { Textarea } from "../ui/textarea";
import { Button, buttonVariants } from "../ui/button";
import { Fcmtoken, getReferralSettings, settingsData } from "@/redux/reducer/settingSlice";
import {
  getUserInfoApi,
  getVerificationStatusApi,
  updateProfileApi,
} from "@/utils/api";
import { toast } from "sonner";
import CustomLink from "@/components/Common/CustomLink";
import PhoneInput from "react-phone-input-2";
import { isValidPhoneNumber } from "libphonenumber-js/max";
import { cn } from "@/lib/utils";
import Loader from "@/components/Common/Loader";
import FollowersFollowingModal from "./FollowersFollowingModal";
import loyaltyCoinImg from '../../public/assets/loyalty-coin.png'
import CustomImage from "../Common/CustomImage";
import { CameraPlusIcon, CircleNotchIcon, ShieldCheckIcon } from "@phosphor-icons/react";

const Profile = () => {
  const UserData = useSelector(userSignUpData);
  const IsLoggedIn = UserData !== undefined && UserData !== null;
  const settings = useSelector(settingsData);
  const placeholder_image = settings?.placeholder_image;
  const [profileImage, setProfileImage] = useState("");
  const [profileFile, setProfileFile] = useState(null);
  const fetchFCM = useSelector(Fcmtoken);
  const [formData, setFormData] = useState({
    name: "",
    email: "",
    phone: "",
    address: "",
    notification: 1,
    show_personal_details: 0,
    region_code: "",
    country_code: "",
  });
  const [errors, setErrors] = useState({ name: "", email: "", address: "", phone: "" });
  const [isLoading, setIsLoading] = useState(false);
  const [isPending, setIsPending] = useState(false);
  const [VerificationStatus, setVerificationStatus] = useState("");
  const [RejectionReason, setRejectionReason] = useState("");
  const [showFollowersModal, setShowFollowersModal] = useState(false);
  const [modalInitialTab, setModalInitialTab] = useState("followers");
  const { refer_earn_enabled } = useSelector(getReferralSettings);


  const getVerificationProgress = async () => {
    try {
      const res = await getVerificationStatusApi.getVerificationStatus();
      if (res?.data?.error === true) {
        setVerificationStatus("not applied");
      } else {
        const status = res?.data?.data?.status;
        const rejectReason = res?.data?.data?.rejection_reason;
        setVerificationStatus(status);
        setRejectionReason(rejectReason);
      }
    } catch (error) {
      console.log(error);
    }
  };

  const getUserDetails = async () => {
    try {
      const res = await getUserInfoApi.getUserInfo();
      if (res?.data?.error === false) {
        const region = (
          res?.data?.data?.region_code ||
          process.env.NEXT_PUBLIC_DEFAULT_COUNTRY ||
          "in"
        ).toLowerCase();

        const countryCode =
          res?.data?.data?.country_code?.replace("+", "") || getDefaultCountryCode();

        setFormData({
          name: res?.data?.data?.name || "",
          email: res?.data?.data?.email || "",
          phone: res?.data?.data?.mobile || "",
          address: res?.data?.data?.address || "",
          notification: res?.data?.data?.notification,
          show_personal_details: Number(res?.data?.data?.show_personal_details),
          region_code: region,
          country_code: countryCode,
        });
        setProfileImage(res?.data?.data?.profile || placeholder_image);
        const currentFcmId = UserData?.fcm_id;
        if (!res?.data?.data?.fcm_id && currentFcmId) {
          const updatedData = { ...res?.data?.data, fcm_id: currentFcmId };
          loadUpdateUserData(updatedData);
        } else {
          loadUpdateUserData(res?.data?.data);
        }
      } else {
        toast.error(res?.data?.message);
      }
    } catch (error) {
      console.log("Error fetching user details:", error);
    }
  };

  useEffect(() => {
    if (IsLoggedIn) {
      const fetchData = async () => {
        setIsPending(true);
        try {
          await Promise.all([getVerificationProgress(), getUserDetails()]);
        } catch (error) {
          console.log("Error in parallel API calls:", error);
        } finally {
          setIsPending(false);
        }
      };
      fetchData();
    }
  }, []);

  const handleChange = (e) => {
    const { id, value } = e.target;
    setFormData((prevData) => ({ ...prevData, [id]: value }));
    setErrors((prev) => ({ ...prev, [id]: "" }));
  };

  const handlePhoneChange = (value, data) => {
    const dial = data?.dialCode || "";
    const iso2 = data?.countryCode || "";
    setFormData((prev) => {
      const pureMobile = value.startsWith(dial) ? value.slice(dial.length) : value;
      return { ...prev, phone: pureMobile, country_code: dial, region_code: iso2 };
    });
    setErrors((prev) => ({ ...prev, phone: "" }));
  };

  const handleSwitchChange = (id) => {
    setFormData((prevData) => ({
      ...prevData,
      [id]: prevData[id] === 1 ? 0 : 1,
    }));
  };

  const handleImageChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      setProfileFile(file);
      const reader = new FileReader();
      reader.onload = () => {
        setProfileImage(reader.result);
      };
      reader.readAsDataURL(file);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    const newErrors = { name: "", email: "", address: "", phone: "" };
    let isValid = true;

    if (!formData.name.trim()) {
      newErrors.name = t("nameRequired");
      isValid = false;
    }
    if (!formData.address.trim()) {
      newErrors.address = t("addressRequired");
      isValid = false;
    }
    const mobileNumber = formData.phone || "";
    if (Boolean(mobileNumber) && !isValidPhoneNumber(`+${formData.country_code}${mobileNumber}`)) {
      newErrors.phone = t("invalidPhoneNumber");
      isValid = false;
    }
    if (formData.email && !/\S+@\S+\.\S+/.test(formData.email)) {
      newErrors.email = t("invalidEmail");
      isValid = false;
    }

    setErrors(newErrors);
    if (!isValid) return;

    try {
      setIsLoading(true);
      const response = await updateProfileApi.updateProfile({
        name: formData.name,
        email: formData.email,
        mobile: mobileNumber,
        address: formData.address,
        profile: profileFile,
        fcm_id: fetchFCM ? fetchFCM : "",
        notification: formData.notification,
        country_code: formData.country_code,
        show_personal_details: formData?.show_personal_details,
        region_code: formData.region_code.toUpperCase(),
      });

      const data = response.data;
      if (data.error !== true) {
        const currentFcmId = UserData?.fcm_id;
        if (!data?.data?.fcm_id && currentFcmId) {
          const updatedData = { ...data?.data, fcm_id: currentFcmId };
          loadUpdateUserData(updatedData);
        } else {
          loadUpdateUserData(data?.data);
        }
        toast.success(data.message);
      } else {
        toast.error(data.message);
      }
    } catch (error) {
      console.error("Error:", error);
    } finally {
      setIsLoading(false);
    }
  };


  // Show loader when pending is true
  if (isPending) {
    return (
      <Loader className="flex justify-center items-center h-full" />
    );
  }

  return (
    <form onSubmit={handleSubmit} className="flex flex-col gap-6">
      <div className="flex flex-col md:flex-row gap-4">
        <div className="flex-1 flex flex-col md:flex-row md:items-center sm:justify-between gap-4 md:border md:p-4 md:rounded">
          <div className="flex flex-col md:flex-row items-center gap-4 flex-1">
            <div className="relative">
              {/* use next js image directly here */}
              {profileImage && (
                <CustomImage
                  src={profileImage}
                  alt="User profile"
                  width={120}
                  height={120}
                  loading="eager"
                  className="w-30 h-auto aspect-square rounded-full border-muted border-4 object-cover"
                />
              )}

              <div className="flex items-center justify-center p-1 absolute size-10 rounded-full top-20 right-0 bg-primary border-4 border-[#efefef] text-white cursor-pointer">
                <input
                  type="file"
                  id="profileImageUpload"
                  className="hidden"
                  accept="image/*"
                  onChange={handleImageChange}
                />
                <label htmlFor="profileImageUpload" className="cursor-pointer">
                  <CameraPlusIcon size={22} />
                </label>
              </div>
            </div>
            <div className="flex flex-col gap-2 flex-1">
              <h1
                className="text-xl text-center md:ltr:text-left md:rtl:text-right font-medium wrap-break-word line-clamp-2"
                title={UserData?.name}
              >
                {UserData?.name}
              </h1>
              <p className="break-all text-center md:ltr:text-left md:rtl:text-right">
                {UserData?.email}
              </p>
            </div>
          </div>
          <div className="md:max-w-[50%] flex justify-center md:justify-end">
            {(() => {
              switch (VerificationStatus) {
                case "approved":
                  return (
                    <div className="flex items-center gap-1 rounded text-white bg-[#05a61d] py-1 px-2 text-sm">
                      <ShieldCheckIcon size={16} weight="fill" />
                      <span>{t("verified")}</span>
                    </div>
                  );

                case "not applied":
                  return (
                    <div className="flex justify-end">
                      <CustomLink
                        href="/user-verification"
                        className={buttonVariants()}
                      >
                        {t("verfiyNow")}
                      </CustomLink>
                    </div>
                  );
                case "pending":
                case "resubmitted":
                  return (
                    <Button type="button" className="cursor-auto">
                      {t("inReview")}
                    </Button>
                  );
                default:
                  return null;
              }
            })()}
          </div>
        </div>
        <div className="flex flex-row md:flex-col justify-around md:justify-center gap-4 bg-white border p-4 rounded-md md:min-w-50">
          <div className="flex flex-col items-center md:items-start gap-1">
            <span>
              {t("followers")}
            </span>
            <button
              type="button"
              className="text-xl font-medium hover:underline"
              onClick={() => {
                setModalInitialTab("followers");
                setShowFollowersModal(true);
              }}
            >
              {UserData?.followers_count || 0}
            </button>
          </div>
          <div className="w-px md:w-full h-auto md:h-px bg-border" />
          <div className="flex flex-col items-center md:items-start gap-1">
            <span>
              {t("following")}
            </span>
            <button
              type="button"
              className="text-xl font-medium hover:underline"
              onClick={() => {
                setModalInitialTab("following");
                setShowFollowersModal(true);
              }}
            >
              {UserData?.following_count || 0}
            </button>
          </div>
        </div>
      </div>
      {showFollowersModal && <FollowersFollowingModal
        isOpen={showFollowersModal}
        onClose={() => setShowFollowersModal(false)}
        initialTab={modalInitialTab}
        followersCount={UserData?.followers_count}
        followingCount={UserData?.following_count}
        userId={UserData?.id}
        updateFollowingCount={() => decreaseFollowing()}
        isSellerPage={false}
      />}
      {VerificationStatus === "rejected" && (
        <div className="md:p-4 md:bg-[#fff5f5] md:border md:border-[#feb2b2] md:rounded-md flex flex-col gap-3">
          <h2 className="text-lg font-semibold">
            {t("applicationRejectionReason")}
          </h2>
          <p className="text-sm leading-relaxed">
            {RejectionReason}
          </p>
          <CustomLink
            href="/user-verification"
            className={buttonVariants() + " w-fit px-4 py-2 text-sm"}
          >
            {t("applyAgain")}
          </CustomLink>
        </div>
      )}

      {/* Loyalty Points */}
      {refer_earn_enabled && <CustomLink href="/profile/loyalty-coins" className="p-3 sm:p-4 bg-muted rounded-xl border flex items-center justify-between">
        <div className="flex items-center gap-4">
          <div className="flex items-center justify-center size-13 sm:size-14 bg-white rounded-xl">
            <CustomImage src={loyaltyCoinImg} width={32} height={32} className="size-7 sm:size-8" />
          </div>
          <div>
            <p className="text-muted-foreground text-lg sm:text-xl font-medium">{t("loyaltyCoins")}</p>
            <p className="text-2xl sm:text-[28px] font-medium">{UserData?.loyalty_points || 0}</p>
          </div>
        </div>
        <div className="bg-black rounded p-1 sm:p-2">
          {/* <MdChevronRight className="size-5 sm:size-6 rtl:scale-x-[-1] text-white" /> */}
        </div>
      </CustomLink>}


      <div className="grid grid-cols-1 md:grid-cols-2 gap-6 md:border md:p-4 md:rounded">
        <h1 className="col-span-full text-xl font-medium">
          {t("personalInfo")}
        </h1>

        <div className="labelInputCont">
          <Label htmlFor="name" className="requiredInputLabel">
            {t("name")}
          </Label>
          <Input
            type="text"
            id="name"
            placeholder={t("enterName")}
            value={formData.name}
            onChange={handleChange}
            className={cn(errors.name && "border-destructive focus-visible:ring-destructive")}
          />
          {errors.name && <span className="text-destructive text-sm">{errors.name}</span>}
        </div>

        <div className="flex flex-colgap-1">
          <div className="w-1/2 flex flex-col gap-3">
            <Label className="font-semibold" htmlFor="notification-mode">
              {t("notification")}
            </Label>
            <Switch
              className="rtl:[direction:rtl]"
              id="notification-mode"
              checked={Number(formData.notification) === 1}
              onCheckedChange={() => handleSwitchChange("notification")}
            />
          </div>
          <div className="w-1/2 flex flex-col gap-3">
            <Label className="font-semibold" htmlFor="showPersonal-mode">
              {t("showContactInfo")}
            </Label>
            <Switch
              id="showPersonal-mode"
              checked={Number(formData.show_personal_details) === 1}
              onCheckedChange={() =>
                handleSwitchChange("show_personal_details")
              }
            />
          </div>
        </div>

        <div className="labelInputCont">
          <Label htmlFor="email" className="requiredInputLabel">
            {t("email")}
          </Label>
          <Input
            type="text"
            id="email"
            placeholder={t("enterEmail")}
            value={formData.email}
            onChange={handleChange}
            readOnly={UserData?.type === "email" || UserData?.type === "google"}
            className={cn(errors.email && "border-destructive focus-visible:ring-destructive")}
          />
          {errors.email && <span className="text-destructive text-sm">{errors.email}</span>}
        </div>
        <div className="labelInputCont">
          <Label htmlFor="phone" className="font-semibold">
            {t("phoneNumber")}
          </Label>
          <PhoneInput
            country={process.env.NEXT_PUBLIC_DEFAULT_COUNTRY}
            value={`${formData.country_code}${formData.phone}`}
            enableLongNumbers
            onChange={(phone, data) => handlePhoneChange(phone, data)}
            inputProps={{ name: "phone" }}
            containerClass={cn("border border-border rounded-md focus-within:ring-2 focus-within:ring-offset-2 focus-within:ring-primary", errors.phone && "border-destructive focus-within:ring-destructive")}
            inputClass="!border-0 !h-10 !w-full !bg-transparent !outline-none !shadow-none"
            buttonClass={cn("!border-0 !border-r !bg-transparent", errors.phone && "!border-r-destructive")}
            disabled={UserData?.type === "phone"}
          />
          {errors.phone && <span className="text-destructive text-sm">{errors.phone}</span>}
        </div>
      </div>
      <div className="md:border md:p-4 md:rounded">
        <h1 className="col-span-full mb-6 text-xl font-medium">
          {t("address")}
        </h1>
        <div className="labelInputCont">
          <Label htmlFor="address" className="requiredInputLabel">
            {t("address")}
          </Label>
          <Textarea
            id="address"
            name="address"
            value={formData.address}
            onChange={handleChange}
            className={cn(errors.address && "border-destructive focus-visible:ring-destructive")}
          />
          {errors.address && <span className="text-destructive text-sm">{errors.address}</span>}
        </div>
      </div>

      <Button disabled={isLoading} className="ltr:ml-auto rtl:mr-auto w-fit">
        {isLoading ?
          <>
            <CircleNotchIcon className="size-4! animate-spin" weight="bold" />
            {t("savingChanges")}
          </>
          :
          t("saveChanges")}
      </Button>
    </form>
  );
};

export default Profile;
