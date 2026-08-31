"use client";
import { t } from "@/utils";
import CustomLink from "@/components/Common/CustomLink";
import { useParams, usePathname } from "next/navigation";
import FirebaseData from "@/utils/Firebase";
import { logoutSuccess, userSignUpData } from "@/redux/reducer/authSlice";
import { toast } from "sonner";
import { useState } from "react";
import { deleteUserApi, logoutApi } from "@/utils/api";
import { deleteUser, getAuth } from "firebase/auth";
import ReusableAlertDialog from "../Common/ReusableAlertDialog";
import DeleteConfirmDialog from "../Common/DeleteConfirmDialog";
import { useSelector } from "react-redux";
import { useNavigate } from "../Hooks/useNavigate";
import DeleteAccountVerifyOtpModal from "../Auth/DeleteAccountVerifyOtpModal";
import {
  getOtpServiceProvider,
  getReferralSettings,
  getDefaultLanguageCode
} from "@/redux/reducer/settingSlice";
// import { PiHandCoins } from "react-icons/pi";
import { BellIcon, BriefcaseIcon, ChatsIcon, CurrencyCircleDollarIcon, HandCoinsIcon, HeartIcon, ReceiptIcon, ShoppingBagOpenIcon, SignOutIcon, StarIcon, TrashSimpleIcon, UserIcon } from "@phosphor-icons/react";

const ProfileSidebar = () => {
  const { lang: langCode } = useParams();
  const { navigate } = useNavigate();
  const pathname = usePathname();
  const userData = useSelector(userSignUpData);
  const otp_service_provider = useSelector(getOtpServiceProvider);
  const [IsLogout, setIsLogout] = useState(false);
  const [IsDeleting, setIsDeleting] = useState(false);
  const [IsDeleteAccount, setIsDeleteAccount] = useState(false);
  const [IsLoggingOut, setIsLoggingOut] = useState(false);
  const [IsVerifyOtpBeforeDelete, setIsVerifyOtpBeforeDelete] = useState(false);
  const { signOut } = FirebaseData();
  const { refer_earn_enabled } = useSelector(getReferralSettings);
  const defaultLangCode = useSelector(getDefaultLanguageCode);

  const isActivePath = (path) => {
    const expected = langCode === defaultLangCode ? path : `/${langCode}${path}`;
    return pathname === expected;
  };

  const handleLogout = async () => {
    try {
      setIsLoggingOut(true);
      await signOut();
      const res = await logoutApi.logoutApi({
        ...(userData?.fcm_id && { fcm_token: userData?.fcm_id }),
      });
      if (res?.data?.error === false) {
        logoutSuccess();
        toast.success(t("signOutSuccess"));
        setIsLogout(false);
        if (pathname !== "/") {
          navigate("/");
        }
      } else {
        toast.error(res?.data?.message);
      }
    } catch (error) {
      console.log("Failed to logout", error);
    } finally {
      setIsLoggingOut(false);
    }
  };


  const handleDeleteAcc = async () => {
    try {
      setIsDeleting(true);
      const auth = getAuth();
      const user = auth.currentUser;
      const isMobileLogin = userData?.type == "phone";
      const needsOtpVerification = isMobileLogin && !user && otp_service_provider === "firebase";
      if (user) {
        await deleteUser(user);
      } else if (needsOtpVerification) {
        setIsDeleteAccount(false);
        setIsVerifyOtpBeforeDelete(true);
        return;
      }
      await deleteUserApi.deleteUser();
      logoutSuccess();
      toast.success(t("userDeleteSuccess"));
      setIsDeleteAccount(false);
      if (pathname !== "/") {
        navigate("/");
      }
    } catch (error) {
      console.error("Error deleting user:", error.message);
      const isMobileLogin = userData?.type === "phone";
      if (error.code === "auth/requires-recent-login" || error.message?.includes("CREDENTIAL_TOO_OLD_LOGIN_AGAIN")) {
        if (isMobileLogin) {
          setIsDeleteAccount(false);
          setIsVerifyOtpBeforeDelete(true);
          return;
        }
        logoutSuccess();
        toast.error(t("deletePop"));
        setIsDeleteAccount(false);
      }
    } finally {
      setIsDeleting(false);
    }
  };

  return (
    <>
      <div className="flex flex-col gap-4 py-6 px-4 h-full">
        <CustomLink
          href="/profile"
          className={`flex items-center gap-1 py-2 px-4 ${isActivePath("/profile") ? "profileActiveTab" : ""
            }`}
        >
          <UserIcon size={24} weight="bold" />
          <span>{t("profile")}</span>
        </CustomLink>
        <CustomLink
          href="/notifications"
          className={`flex items-center gap-1 py-2 px-4 ${isActivePath("/notifications") ? "profileActiveTab" : ""
            }`}
        >
          <BellIcon size={24} weight="bold" />
          <span>{t("notifications")}</span>
        </CustomLink>
        <CustomLink
          href="/chat"
          className={`flex items-center gap-1 py-2 px-4 ${isActivePath("/chat") ? "profileActiveTab" : ""
            }`}
        >
          <ChatsIcon size={24} weight="bold" />
          <span>{t("chat")}</span>
        </CustomLink>
        <CustomLink
          href="/user-subscription"
          className={`flex items-center gap-1 py-2 px-4 ${isActivePath("/user-subscription") ? "profileActiveTab" : ""
            }`}
        >
          <CurrencyCircleDollarIcon size={24} weight="bold" />
          <span>{t("subscription")}</span>
        </CustomLink>
        {refer_earn_enabled && (
          <CustomLink
            href="/refer-and-earn"
            className={`flex items-center gap-1 py-2 px-4 ${isActivePath("/refer-and-earn") ? "profileActiveTab" : ""
              }`}
          >
            <HandCoinsIcon size={24} weight="bold" />
            <span>{t("referAndEarn")}</span>
          </CustomLink>
        )}
        <CustomLink
          href="/my-ads"
          className={`flex items-center gap-1 py-2 px-4 ${isActivePath("/my-ads") ? "profileActiveTab" : ""
            }`}
        >
          <ShoppingBagOpenIcon size={24} weight="bold" />
          <span>{t("myAds")}</span>
        </CustomLink>
        <CustomLink
          href="/favorites"
          className={`flex items-center gap-1 py-2 px-4 ${isActivePath("/favorites") ? "profileActiveTab" : ""
            }`}
        >
          <HeartIcon size={24} weight="bold" />
          <span>{t("favorites")}</span>
        </CustomLink>
        <CustomLink
          href="/transactions"
          className={`flex items-center gap-1 py-2 px-4 ${isActivePath("/transactions") ? "profileActiveTab" : ""
            }`}
        >
          <ReceiptIcon size={24} weight="bold" />
          <span>{t("transaction")}</span>
        </CustomLink>
        <CustomLink
          href="/reviews"
          className={`flex items-center gap-1 py-2 px-4 ${isActivePath("/reviews") ? "profileActiveTab" : ""
            }`}
        >
          <StarIcon size={24} weight="bold" />
          <span>{t("myReviews")}</span>
        </CustomLink>
        <CustomLink
          href="/job-applications"
          className={`flex items-center gap-1 py-2 px-4 ${isActivePath("/job-applications") ? "profileActiveTab" : ""
            }`}
        >
          <BriefcaseIcon size={24} weight="bold" />
          <span>{t("jobApplications")}</span>
        </CustomLink>

        <button
          onClick={() => setIsLogout(true)}
          className="flex items-center gap-1 py-2 px-4"
        >
          <SignOutIcon size={24} weight="bold" />
          <span>{t("signOut")}</span>
        </button>
        <button
          onClick={() => setIsDeleteAccount(true)}
          className="flex items-center gap-1 py-2 px-4 text-destructive"
        >
          <TrashSimpleIcon size={24} weight="bold" />
          <span>{t("deleteAccount")}</span>
        </button>
      </div>

      {/* Logout Alert Dialog */}
      <ReusableAlertDialog
        open={IsLogout}
        onCancel={() => setIsLogout(false)}
        onConfirm={handleLogout}
        title={t("confirmLogout")}
        description={t("areYouSureToLogout")}
        cancelText={t("cancel")}
        confirmText={t("yes")}
        confirmDisabled={IsLoggingOut}
      />

      {/* Delete Account Alert Dialog */}
      <DeleteConfirmDialog
        open={IsDeleteAccount}
        onCancel={() => setIsDeleteAccount(false)}
        onConfirm={handleDeleteAcc}
        title={t("areYouSure")}
        description={
          <ul className="list-disc list-inside mt-2 ltr:text-left rtl:text-right">
            <li>{t("adsAndTransactionWillBeDeleted")}</li>
            <li>{t("accountsDetailsWillNotRecovered")}</li>
            <li>{t("subWillBeCancelled")}</li>
            <li>{t("savedMesgWillBeLost")}</li>
          </ul>
        }
        cancelText={t("cancel")}
        confirmText={t("yesDelete")}
        confirmDisabled={IsDeleting}
      />
      <DeleteAccountVerifyOtpModal
        isOpen={IsVerifyOtpBeforeDelete}
        setIsOpen={setIsVerifyOtpBeforeDelete}
        key={IsVerifyOtpBeforeDelete}
        pathname={pathname}
        navigate={navigate}
      />
    </>
  );
};

export default ProfileSidebar;
