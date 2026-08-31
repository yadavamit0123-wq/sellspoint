import { useState } from "react";
import { Badge } from "@/components/ui/badge";
import { useSelector } from "react-redux";
import { extractYear, getDefaultCountryCode, t } from "@/utils";
import CustomLink from "@/components/Common/CustomLink";
import { getSellerProfilePath } from "@/utils/seller";
import { itemOfferApi, chatListApi } from "@/utils/api";
import { toast } from "sonner";
import { userSignUpData } from "@/redux/reducer/authSlice";
import MakeOfferModal from "./MakeOfferModal";
import { setIsLoginOpen } from "@/redux/reducer/globalStateSlice";
import ApplyJobModal from "./ApplyJobModal";
import CustomImage from "@/components/Common/CustomImage";
import Link from "next/link";
import { useNavigate } from "@/components/Hooks/useNavigate";
import { ArrowRightIcon, ChatTeardropDotsIcon, GiftIcon, PaperPlaneTiltIcon, PhoneCallIcon, ShieldCheckIcon, StarIcon } from "@phosphor-icons/react";

const SellerDetailCard = ({ productDetails, setProductDetails }) => {
  const { navigate } = useNavigate();
  const userData = productDetails && productDetails?.user;
  const memberSinceYear = userData?.created_at
    ? extractYear(userData.created_at)
    : "";
  const [IsStartingChat, setIsStartingChat] = useState(false);
  const loggedInUser = useSelector(userSignUpData);
  const loggedInUserId = loggedInUser?.id;
  const [IsOfferModalOpen, setIsOfferModalOpen] = useState(false);
  const [showApplyModal, setShowApplyModal] = useState(false);
  const [showNumber, setShowNumber] = useState(false);

  const isAllowedToMakeOffer =
    productDetails?.price > 0 &&
    !productDetails?.is_already_offered &&
    Number(productDetails?.category?.is_job_category) === 0
  const isJobCategory = Number(productDetails?.category?.is_job_category) === 1;
  const isApplied = productDetails?.is_already_job_applied;
  const item_id = productDetails?.id;

  const handleChat = async () => {
    if (!loggedInUserId) {
      setIsLoginOpen(true);
      return;
    }
    try {
      setIsStartingChat(true);
      const isAlreadyOffered = productDetails?.is_already_offered;
      if (isAlreadyOffered) {
        const item_offer_id = productDetails?.item_offers?.[0]?.id;
        const response = await chatListApi.chatList({ type: "buyer", item_offer_id });
        if (response?.data?.error === false) {
          const chatId = response?.data?.data?.data[0]?.id;
          const adId = response?.data?.data?.data[0]?.item?.id;
          navigate("/chat?activeTab=buying&chatid=" + chatId + '&chat_ad_id=' + adId);
        } else {
          toast.error(response?.data?.message);
        }
      } else {
        const response = await itemOfferApi.offer({
          item_id: productDetails?.id,
        });
        if (response?.data?.error === false) {
          const { data } = response.data;
          navigate("/chat?activeTab=buying&chatid=" + data?.id + '&chat_ad_id=' + productDetails?.id);
        } else {
          toast.error(response?.data?.message);
        }
      }
    } catch (error) {
      toast.error(t("unableToStartChat"));
      console.log(error);
    } finally {
      setIsStartingChat(false);
    }
  };

  const handleMakeOffer = () => {
    if (!loggedInUserId) {
      setIsLoginOpen(true);
      return;
    }
    setIsOfferModalOpen(true);
  };

  const handleApplyJob = () => {
    if (!loggedInUserId) {
      setIsLoginOpen(true);
      return;
    }
    setShowApplyModal(true);
  };


  const sellerPath = getSellerProfilePath(userData);

  const contactNumber = productDetails?.contact;

  const regionCode = productDetails?.region_code?.toUpperCase();
  const countryCode = getDefaultCountryCode(regionCode) || "";

  const prefix = countryCode ? `+${countryCode}` : "";
  const mobile = contactNumber ? `${prefix}${contactNumber}` : null;
  return (
    <>
      <div className="flex items-center rounded-lg border flex-col">
        {(userData?.is_verified == 1 || memberSinceYear) && (
          <div className="p-4 flex justify-between items-center w-full">
            {productDetails?.user?.is_verified == 1 && (
              <Badge
                variant="outline"
                className="p-1 bg-[#05a61d] flex items-center gap-1 rounded-md text-white text-sm"
              >
                <ShieldCheckIcon size={20} weight="fill" />
                {t("verified")}
              </Badge>
            )}
            {memberSinceYear && (
              <p className="ltr:ml-auto rtl:mr-auto text-sm text-muted-foreground">
                {t("memberSince")}: {memberSinceYear}
              </p>
            )}
          </div>
        )}
        <div className="border-b w-full"></div>
        <div className="flex gap-2 justify-between w-full items-center p-4">
          <div className="flex gap-2.5 items-center max-w-[90%]">
            <CustomImage
              onClick={() => navigate(sellerPath)}
              src={productDetails?.user?.profile}
              alt="Seller Image"
              width={80}
              height={80}
              className="w-20 aspect-square rounded-lg cursor-pointer"
            />
            <div className="flex flex-col gap-1 min-w-0">
              <CustomLink
                href={sellerPath}
                className="font-bold text-lg truncate"
              >
                {productDetails?.user?.name}
              </CustomLink>
              {productDetails?.user?.reviews_count > 0 &&
                productDetails?.user?.average_rating && (
                  <div className="flex items-center gap-1 text-sm">
                    <StarIcon size={20} className="text-black" weight="fill" />
                    <p className="flex">
                      {Number(productDetails?.user?.average_rating).toFixed(2)}
                    </p>{" "}
                    |{" "}
                    <p className="flex text-sm ">
                      {productDetails?.user?.reviews_count}
                    </p>{" "}
                    {t("ratings")}
                  </div>
                )}
            </div>
          </div>
          <CustomLink href={sellerPath}>
            <ArrowRightIcon size={20} className="text-black rtl:scale-x-[-1]" />
          </CustomLink>
        </div>
        <div className="border-b w-full"></div>
        <div className="flex flex-wrap items-center gap-4 p-4 w-full">
          <button
            onClick={handleChat}
            disabled={IsStartingChat}
            className="bg-black text-white p-4 rounded-md flex items-center gap-2 text-base font-medium justify-center whitespace-nowrap flex-[1_1_47%]"
          >
            <ChatTeardropDotsIcon size={22} />
            {IsStartingChat ? (
              <span>{t("startingChat")}</span>
            ) : (
              <span>{t("startChat")}</span>
            )}
          </button>

          {mobile && (
            <>
              {/* 📱 MOBILE VIEW: Shows "Call" label and redirects immediately */}
              <Link
                href={`tel:${mobile}`}
                className="lg:hidden bg-black text-white p-4 rounded-md flex items-center gap-2 text-base font-medium justify-center whitespace-nowrap flex-[1_1_47%]"
              >
                <PhoneCallIcon size={21} />
                <span>{t("call")}</span>
              </Link>

              {/* 💻 DESKTOP VIEW: Toggle Button to reveal/hide number */}
              <button
                onClick={() => setShowNumber(prev => !prev)}
                className="hidden lg:flex bg-black text-white p-4 rounded-md items-center gap-2 text-base font-medium justify-center whitespace-nowrap flex-[1_1_47%]"
              >
                <PhoneCallIcon size={21} />
                <span>{showNumber ? mobile : t("showMobileNumber")}</span>
              </button>
            </>
          )}

          {isAllowedToMakeOffer && (
            <button
              onClick={handleMakeOffer}
              className="bg-primary text-white p-4 rounded-md flex items-center gap-2 text-base font-medium justify-center whitespace-nowrap flex-[1_1_47%]"
            >
              <GiftIcon size={21} />
              {t("makeOffer")}
            </button>
          )}
          {isJobCategory && (
            <button
              className={`text-white p-4 rounded-md flex items-center gap-2 text-base font-medium justify-center whitespace-nowrap flex-[1_1_47%] ${isApplied ? "bg-primary" : "bg-black"
                }`}
              disabled={isApplied}
              onClick={handleApplyJob}
            >
              <PaperPlaneTiltIcon size={20} />
              {isApplied ? t("applied") : t("applyNow")}
            </button>
          )}
        </div>
      </div>

      <MakeOfferModal
        isOpen={IsOfferModalOpen}
        onClose={() => setIsOfferModalOpen(false)}
        productDetails={productDetails}
        key={`offer-modal-${IsOfferModalOpen}`}
      />
      <ApplyJobModal
        key={`apply-job-modal-${showApplyModal}`}
        showApplyModal={showApplyModal}
        setShowApplyModal={setShowApplyModal}
        item_id={item_id}
        setProductDetails={setProductDetails}
      />
    </>
  );
};

export default SellerDetailCard;
