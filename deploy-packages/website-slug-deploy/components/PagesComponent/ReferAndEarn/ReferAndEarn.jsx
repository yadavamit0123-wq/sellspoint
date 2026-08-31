'use client'
import CustomImage from "@/components/Common/CustomImage"
import referAndEarnImg from '../../../public/assets/refer-and-earn.png'
import { t } from "@/utils"
import { Separator } from "@/components/ui/separator"
// import { FaArrowDown } from "react-icons/fa"
import { cn } from "@/lib/utils"
// import { AiOutlineGift } from "react-icons/ai"
import { Button } from "@/components/ui/button"
import { getReferralCodeApi } from "@/utils/api"
import { useEffect, useState } from "react"
import { toast } from "sonner"

const ReferAndEarn = () => {
  const [isLoading, setIsLoading] = useState(true)
  const [referralCode, setReferralCode] = useState('')
  const [copied, setCopied] = useState(false)

  const steps = [
    {
      id: "01",
      text: t("shareReferralCode"),
    },
    {
      id: "02",
      text: t("yourFriendSignsUpAndBuyTheSubscription"),
    },
    {
      id: "03",
      text: t("receiveRewardPoints"),
    },
  ];

  const handleCopyUrl = async () => {
    try {
      await navigator.clipboard.writeText(referralCode);
      setCopied(true);
      setTimeout(() => {
        setCopied(false);
      }, 3000);
    } catch (error) {
      console.error("Error copying to clipboard:", error);
    }
  };

  useEffect(() => {
    getReferralCode()
  }, [])

  const getReferralCode = async () => {
    try {
      const res = await getReferralCodeApi.getReferralCode();
      if (res?.data?.error === false) {
        setReferralCode(res?.data?.data?.referral_code)
      } else {
        toast.error(res?.data?.message)
      }
    } catch (error) {
      console.log('error', error)
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <>
      <div className="flex justify-center">
        <CustomImage loading="eager" src={referAndEarnImg} width={465} height={400} alt="Refer and Earn" />
      </div>
      <div className="mt-6">
        <h6 className="text-sm font-bold text-muted-foreground" >{t("howItWorks")}</h6>
        {steps.map((step, index) => (
          <div
            key={step.id}
            className={cn(
              "flex flex-col text-muted-foreground group gap-1",
              index === 0 ? "mt-4" : "mt-1"
            )}
          >
            <div className="flex items-center gap-8">
              <div className="shrink-0 size-8 sm:size-9 flex items-center justify-center bg-muted rounded group-hover:bg-primary group-hover:text-white transition-colors duration-300">
                <span className="text-lg sm:text-xl font-medium">{step.id}</span>
              </div>

              <p className="text-lg sm:text-xl font-medium group-hover:text-black transition-colors duration-300">
                {step.text}
              </p>
            </div>

            <div className="flex items-center gap-8 w-full">
              <div
                className={cn(
                  "shrink-0 size-9 flex items-center justify-center",
                  index === steps.length - 1 && "invisible"
                )}
              >
                {/* <FaArrowDown className="size-3.5" /> */}
              </div>
              <Separator className="flex-1 group-hover:bg-primary" />
            </div>
          </div>
        ))}
      </div>

      <div className="mt-6 flex flex-col gap-2">
        <p>{t("referralCode")}</p>
        <div className="flex items-center gap-4">
          <div className="bg-muted py-2 px-3 flex items-center gap-3 rounded border flex-1">
            {/* <AiOutlineGift className='size-4 text-muted-foreground' /> */}
            <span>{isLoading ? t('loading') : referralCode}</span>
          </div>
          <Button onClick={handleCopyUrl} disabled={copied || isLoading} className='px-3 py-1.5 text-base font-normal'>
            {copied ? t('copied') : t('copyCode')}
          </Button>
        </div>
      </div>
    </>
  )
}

export default ReferAndEarn