"use client";
import { useEffect, useRef, useState } from "react";
import { useSwipeable } from "react-swipeable";
import { useRouter, useParams, useSearchParams } from "next/navigation";
import { useNavigate } from "@/components/Hooks/useNavigate";
import { useDebouncedToggle } from "@/components/Hooks/useDebouncedToggle";
import { useSelector } from "react-redux";
import { getReelsApi, getMyReelsApi, manageReelLikeApi, followUserApi, unfollowUserApi, itemOfferApi, chatListApi } from "@/utils/api.js";
import { getIsLoggedIn, userSignUpData } from "@/redux/reducer/authSlice";
import { setIsLoginOpen } from "@/redux/reducer/globalStateSlice";
import { getCompanyName, getDefaultLanguageCode } from "@/redux/reducer/settingSlice";
import ShareDropdown from "@/components/Common/ShareDropdown";
import { toast } from "sonner";
import { t } from "@/utils";
import { cn } from "@/lib/utils";
import CustomImage from "@/components/Common/CustomImage";
import CustomLink from "@/components/Common/CustomLink";
import NoData from "@/components/EmptyStates/NoData";
import {
  ArrowUpIcon,
  ArrowDownIcon,
  HeartIcon,
  SpeakerHighIcon,
  SpeakerSlashIcon,
  PlayIcon,
  CircleNotchIcon,
  ChatsIcon,
  ArrowLeftIcon,
} from "@phosphor-icons/react";

const PER_PAGE = 10;

const TABS = [
  { key: "foryou", label: "For You" },
  { key: "following", label: "Following" },
];

const ActionButtons = ({ isMuted, onToggleMute, onLike, isLiked, likedCount, onChat, isStartingChat, isSelf, shareUrl, shareTitle, shareHeadline, companyName }) => (
  <div className="flex flex-col items-center gap-4 md:gap-6">
    {!isSelf && (
      <button onClick={onLike} className="flex flex-col items-center gap-1">
        <div className="bg-white rounded-full transition-colors p-2">
          <HeartIcon size={20} color={isLiked ? "var(--destructive)" : "black"} weight={isLiked ? "fill" : "regular"} />
        </div>
        <span className="text-white text-xs md:text-base">
          {likedCount > 0 ? likedCount : t('like')}
        </span>
      </button>
    )}
    {!isSelf && (
      <button onClick={onChat} disabled={isStartingChat} className="flex flex-col items-center gap-1">
        <div className="bg-white rounded-full transition-colors p-2">
          {isStartingChat
            ? <CircleNotchIcon size={20} color="black" className="animate-spin" />
            : <ChatsIcon size={20} color="black" />
          }
        </div>
        <span className="text-white text-xs md:text-base">{t('chat')}</span>
      </button>
    )}
    <div className="flex flex-col items-center gap-1">
      <ShareDropdown
        url={shareUrl}
        title={shareTitle}
        headline={shareHeadline}
        companyName={companyName}
        className={cn("bg-white rounded-full transition-colors hover:bg-gray-100 flex items-center justify-center p-2")}
      />
      <span className="text-white text-xs md:text-base">{t('share')}</span>
    </div>
    <button onClick={onToggleMute} className="flex flex-col items-center gap-1">
      <div className={cn("bg-white rounded-full transition-colors p-2")}>
        {isMuted ? <SpeakerSlashIcon size={20} color="black" /> : <SpeakerHighIcon size={20} color="black" />}
      </div>
      <span className="text-white text-xs md:text-base">{t('sound')}</span>
    </button>
  </div>
);

const ReelPlayer = ({ initialId }) => {
  const router = useRouter();
  const { lang } = useParams();
  const searchParams = useSearchParams();
  const { navigate, replaceState } = useNavigate();
  const videoRef = useRef(null);
  const isLoggedIn = useSelector(getIsLoggedIn);
  const userData = useSelector(userSignUpData);
  const companyName = useSelector(getCompanyName);
  const defaultLangCode = useSelector(getDefaultLanguageCode);
  const isOwnerMode = isLoggedIn && searchParams.get("owner") === "1";
  const reelUrl = (id) => (isOwnerMode ? `/reel/${id}?owner=1` : `/reel/${id}`);

  const [reels, setReels] = useState([]);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [isLoading, setIsLoading] = useState(true);
  const [isMuted, setIsMuted] = useState(true);
  const [isPaused, setIsPaused] = useState(false);
  const [direction, setDirection] = useState("next");
  const [activeTab, setActiveTab] = useState("foryou");
  const [isStartingChat, setIsStartingChat] = useState(false);
  const [isFetchingMore, setIsFetchingMore] = useState(false);
  const [hasMore, setHasMore] = useState(true);


  const pageRef = useRef(1);
  const wheelLockRef = useRef(false);
  const toggleLike = useDebouncedToggle();
  const toggleFollow = useDebouncedToggle();

  const fetchReels = async (tab) => {
    setIsLoading(true);
    try {
      const res = isOwnerMode
        ? await getMyReelsApi.getMyReels({ reel_id: initialId, per_page: PER_PAGE, page: 1 })
        : await getReelsApi.getReels({
          reel_id: tab === "foryou" ? initialId : undefined,
          per_page: PER_PAGE,
          page: 1,
          following: tab === "following" ? 1 : undefined,
        });
      if (res?.data?.error === false) {
        const data = res?.data?.data;
        const newReels = data?.data || [];
        setReels(newReels);
        setHasMore(data?.current_page < data?.last_page);
        setCurrentIndex(0);
        pageRef.current = 1;
        if (newReels[0]?.id) replaceState(reelUrl(newReels[0].id));
      } else {
        toast.error(res?.data?.message);
      }
    } catch (err) {
      console.error("Reels fetch error:", err);
    } finally {
      setIsLoading(false);
    }
  };

  // Downward swipe would otherwise trigger the browser's native pull-to-refresh
  // before react-swipeable finishes recognizing the gesture — block overscroll
  // chaining on the document while this full-screen player is mounted.
  useEffect(() => {
    const html = document.documentElement;
    const prevOverscroll = html.style.overscrollBehaviorY;
    html.style.overscrollBehaviorY = "contain";
    return () => {
      html.style.overscrollBehaviorY = prevOverscroll;
    };
  }, []);

  useEffect(() => {
    fetchReels(activeTab);
  }, [activeTab]);

  const fetchMoreReels = async () => {
    if (isFetchingMore || !hasMore) return;
    setIsFetchingMore(true);
    try {
      const nextPage = pageRef.current + 1;
      const res = isOwnerMode
        ? await getMyReelsApi.getMyReels({ per_page: PER_PAGE, page: nextPage })
        : await getReelsApi.getReels({ per_page: PER_PAGE, page: nextPage, following: activeTab === "following" ? 1 : undefined });
      if (res?.data?.error === false) {
        const data = res?.data?.data;
        const newReels = data?.data || [];
        if (newReels.length) {
          pageRef.current = nextPage;
          setReels((prev) => [...prev, ...newReels]);
        }
        setHasMore(data?.current_page < data?.last_page);
      }
    } catch (err) {
      console.error("Fetch more reels error:", err);
    } finally {
      setIsFetchingMore(false);
    }
  };

  useEffect(() => {
    const handler = (e) => {
      if (e.key === "ArrowUp") goPrev();
      if (e.key === "ArrowDown") goNext();
      if (e.key === "Escape") handleClose();
    };
    window.addEventListener("keydown", handler);
    return () => window.removeEventListener("keydown", handler);
  }, [reels.length, currentIndex]);

  const handleClose = () => {
    router.back();
  };

  const goPrev = () => {
    if (currentIndex === 0) return;
    const next = currentIndex - 1;
    if (reels[next]?.id) replaceState(reelUrl(reels[next].id));
    setDirection("prev");
    setCurrentIndex(next);
  };

  const goNext = () => {
    if (currentIndex === reels.length - 1) return;
    const next = currentIndex + 1;
    if (reels[next]?.id) replaceState(reelUrl(reels[next].id));
    if (hasMore && next >= reels.length - 3) fetchMoreReels();
    setDirection("next");
    setCurrentIndex(next);
  };

  const swipeHandlers = useSwipeable({
    onSwipedUp: goNext,
    onSwipedDown: goPrev,
    preventScrollOnSwipe: true,
    delta: 50,
    trackMouse: false,
  });

  const handleWheel = (e) => {
    if (wheelLockRef.current || Math.abs(e.deltaY) < 10) return;
    wheelLockRef.current = true;
    if (e.deltaY > 0) goNext();
    else goPrev();
    setTimeout(() => {
      wheelLockRef.current = false;
    }, 600);
  };

  const handleChat = async () => {
    if (!isLoggedIn) {
      setIsLoginOpen(true);
      return;
    }
    setIsStartingChat(true);
    try {
      const currentReel = reels[currentIndex];
      const isAlreadyOffered = currentReel?.item?.is_item_offered
      if (isAlreadyOffered) {
        const item_offer_id = currentReel?.item?.offer_item_id
        const res = await chatListApi.chatList({ type: "buyer", item_offer_id });
        if (res?.data?.error === false) {
          const chatId = res?.data?.data?.data[0]?.id
          const adId = res?.data?.data?.data[0]?.item?.id
          navigate(`/chat?activeTab=buying&chatid=${chatId}&chat_ad_id=${adId}`);
        } else {
          toast.error(res?.data?.message);
        }
      } else {
        const res = await itemOfferApi.offer({ item_id: reels[currentIndex]?.item?.id });
        if (res?.data?.error === false) {
          const { data } = res.data;
          navigate(`/chat?activeTab=buying&chatid=${data?.id}&chat_ad_id=${reels[currentIndex]?.item?.id}`);
        } else {
          toast.error(res?.data?.message);
        }
      }
    } catch {
      toast.error(t("unableToStartChat"));
    } finally {
      setIsStartingChat(false);
    }
  };

  const handleLike = () => {
    if (!isLoggedIn) {
      setIsLoginOpen(true);
      return;
    }
    const reel = reels[currentIndex];
    if (!reel?.id) return;
    const reelId = reel.id;

    const setLiked = (liked) =>
      setReels((prev) =>
        prev.map((r) => (r.id === reelId ? { ...r, is_liked: liked, liked_count: r.liked_count + (liked ? 1 : -1) } : r))
      );

    toggleLike(
      reelId,
      reel.is_liked,
      setLiked,
      () => manageReelLikeApi.manageReelLike({ reel_id: reelId }),
      (res) => toast.error(res?.data?.message || t("failedToLike"))
    );
  };

  const handleFollow = () => {
    const currentReel = reels[currentIndex];
    const userId = currentReel?.item?.user?.id;
    if (!userId) return;

    const setFollowing = (following) =>
      setReels((prev) =>
        prev.map((r) =>
          r.item?.user?.id === userId
            ? { ...r, item: { ...r.item, user: { ...r.item.user, is_following: following } } }
            : r
        )
      );

    toggleFollow(
      userId,
      currentReel.item.user.is_following,
      setFollowing,
      () => {
        const api = !currentReel.item.user.is_following ? followUserApi.followUser : unfollowUserApi.unfollowUser;
        return api({ user_id: userId });
      },
      (res) => toast.error(res?.data?.message || t("somethingWentWrong"))
    );
  };

  const togglePlay = () => {
    if (!videoRef.current) return;
    if (videoRef.current.paused) {
      videoRef.current.play();
      setIsPaused(false);
    } else {
      videoRef.current.pause();
      setIsPaused(true);
    }
  };

  if (isLoading) {
    return (
      <div className="fixed inset-0 bg-[#1c1c1c] flex items-center justify-center z-50">
        <div className="w-8 h-8 border-2 border-white border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  const reel = reels[currentIndex];
  const isSelf = Number(userData?.id) === Number(reel?.item?.user?.id);
  const isJobCategory = Number(reel?.item?.category?.is_job_category) === 1;
  const itemPrice = isJobCategory ? reel?.item?.formatted_salary_range : reel?.item?.formatted_price;
  const isHidePrice = isJobCategory ? !reel?.item?.formatted_salary_range : !reel?.item?.formatted_price;

  const reelPath = lang === defaultLangCode ? `/reel/${reel?.id}` : `/${lang}/reel/${reel?.id}`;
  const shareUrl = `${process.env.NEXT_PUBLIC_WEB_URL}${reelPath}`;
  const shareTitle = `${reel?.item?.translated_name || reel?.item?.name} | ${companyName}`;
  const shareHeadline = `🚀 Discover the perfect deal! Explore "${reel?.item?.translated_name || reel?.item?.name}" from ${companyName} and grab it before it's gone. Shop now at`;

  return (
    <div {...swipeHandlers} className="fixed inset-0 bg-[#1c1c1c] flex items-center justify-center z-50">
      {/* Close */}
      <button
        onClick={handleClose}
        className="absolute top-4 ltr:left-4 rtl:right-4 z-10 bg-white hover:bg-gray-100 rounded-full p-2 transition-colors"
      >
        <ArrowLeftIcon size={20} color="black" weight="bold" className="rtl:scale-x-[-1]" />
      </button>

      {/* Center: video + action sidebar */}
      <div className="flex items-end gap-4">
        {/* width = min(viewport width, 90dvh * 9/16) — never overflows either axis */}
        <div onWheel={handleWheel} className="relative w-[min(100vw,calc(90dvh*9/16))] aspect-9/16 rounded-2xl overflow-hidden bg-[#1c1c1c]">

          {/* Tabs — inside video area, always visible */}
          {isLoggedIn && !isOwnerMode && (
            <div className="absolute top-4 inset-x-0 z-10 flex items-center justify-center gap-4">
              {TABS.map((tab, i) => (
                <div key={tab.key} className="flex items-center gap-4">
                  <button
                    onClick={() => setActiveTab(tab.key)}
                    className={cn(
                      "text-sm",
                      activeTab === tab.key ? "text-white" : "text-white/60"
                    )}
                  >
                    {tab.label}
                  </button>
                  {i === 0 && <span className="text-white text-sm">|</span>}
                </div>
              ))}
            </div>
          )}

          {reels.length === 0 ? (
            <div className="w-full h-full flex items-center justify-center text-white max-w-2/3]">
              <NoData title={t("noReelsFound")} />
            </div>
          ) : (
            <div
              key={reel?.id}
              className={cn(
                "absolute inset-0 animate-in duration-300 ease-out",
                direction === "next" ? "slide-in-from-bottom-full" : "slide-in-from-top-full"
              )}
            >
              <video
                ref={videoRef}
                src={reel?.video}
                autoPlay
                playsInline
                muted={isMuted}
                loop
                controlsList="nodownload"
                onClick={togglePlay}
                onContextMenu={(e) => e.preventDefault()}
                className="w-full h-full object-cover cursor-pointer"
              />

              {/* Pause overlay */}
              {isPaused && (
                <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
                  <div className="bg-black/50 rounded-full p-4">
                    <PlayIcon size={40} weight="fill" color="white" />
                  </div>
                </div>
              )}

              {/* Mobile-only: actions inside video, right side */}
              <div className="md:hidden absolute right-2 top-1/2 -translate-y-1/2 z-10">
                <ActionButtons isMuted={isMuted} onToggleMute={() => setIsMuted((m) => !m)} onLike={handleLike} isLiked={reel?.is_liked} likedCount={reel?.liked_count} onChat={handleChat} isStartingChat={isStartingChat} isSelf={isSelf} shareUrl={shareUrl} shareTitle={shareTitle} shareHeadline={shareHeadline} companyName={companyName} />
              </div>

              {/* Bottom overlay: user + product */}
              <div className="absolute bottom-0 inset-x-0 bg-linear-to-t from-black/90 via-black/30 to-transparent p-4 space-y-3">
                {/* User row */}
                <div className="flex items-center gap-2">
                  <CustomLink href={isSelf ? "/profile" : `/seller/${reel?.item?.user?.id}`} className="flex items-center gap-2 min-w-0">
                    <CustomImage
                      src={reel?.item?.user?.profile}
                      alt={reel?.item?.user?.name}
                      width={40}
                      height={40}
                      className="size-9 md:size-10 rounded-full object-cover shrink-0"
                    />
                    <span className="text-white text-sm md:text-xl font-semibold truncate">
                      {reel?.item?.user?.name}
                    </span>
                  </CustomLink>
                  {isLoggedIn && !isSelf && (
                    <button
                      onClick={handleFollow}
                      className="ml-auto shrink-0 bg-white text-black text-xs md:text-sm px-3 py-1 rounded-full flex items-center gap-1">
                      {reel?.item?.user?.is_following ? t("following") : t("follow")}
                    </button>
                  )}
                </div>

                {/* Product card */}
                <CustomLink
                  href={isSelf ? `/my-listing/${reel?.item?.slug}` : `/ad-details/${reel?.item?.slug}`}
                  className="flex items-center gap-3 bg-white/80 rounded-xl"
                >
                  <CustomImage
                    src={reel?.item?.image}
                    alt={reel?.item?.translated_name}
                    width={134}
                    height={134}
                    className="size-16 md:size-32 object-cover rounded-s-lg shrink-0"
                  />
                  <div className="flex flex-col gap-1 min-w-0">
                    <p className="text-black text-sm md:text-xl line-clamp-2">
                      {reel?.item?.translated_name}
                    </p>
                    {!isHidePrice && (
                      <p className="text-primary text-xs md:text-2xl font-bold">
                        {itemPrice}
                      </p>
                    )}
                  </div>
                </CustomLink>
              </div>
            </div>
          )}
        </div>

        {/* Desktop-only: actions outside video */}
        {reels.length > 0 && (
          <div className="hidden md:block">
            <ActionButtons isMuted={isMuted} onToggleMute={() => setIsMuted((m) => !m)} onLike={handleLike} isLiked={reel?.is_liked} likedCount={reel?.liked_count} onChat={handleChat} isStartingChat={isStartingChat} isSelf={isSelf} shareUrl={shareUrl} shareTitle={shareTitle} shareHeadline={shareHeadline} companyName={companyName} />
          </div>
        )}
      </div>

      {/* Prev / Next navigation — desktop only */}
      {
        reels.length > 0 && <div className="hidden md:flex absolute ltr:right-6 rtl:left-6 top-1/2 -translate-y-1/2 flex-col gap-3">
          <button
            onClick={goPrev}
            disabled={currentIndex === 0}
            className={cn("bg-white hover:bg-gray-100 rounded-full p-2 transition-colors", currentIndex === 0 ? "opacity-40 cursor-not-allowed" : "")}
          >
            <ArrowUpIcon size={20} color="black" weight="bold" />
          </button>
          <button
            onClick={goNext}
            disabled={currentIndex === reels.length - 1 && !hasMore}
            className={cn("bg-white hover:bg-gray-100 rounded-full p-2 transition-colors", currentIndex === reels.length - 1 && !hasMore ? "opacity-40 cursor-not-allowed" : "")}
          >
            {isFetchingMore && currentIndex >= reels.length - 3
              ? <CircleNotchIcon size={20} color="black" className="animate-spin" />
              : <ArrowDownIcon size={20} color="black" weight="bold" />
            }
          </button>
        </div>
      }
    </div >
  );
};

export default ReelPlayer;
