"use client";

import { useEffect, useMemo, useState } from "react";
import { useParams } from "next/navigation";
import { toast } from "sonner";
import { t } from "@/utils";
import Loader from "@/components/Common/Loader";
import SellerDetailCard from "@/components/PagesComponent/Seller/SellerDetailCard";
import { getItemApi, getSellerApi } from "@/utils/api";
import { parseSellerIdFromSlug } from "@/utils/seller";
import CustomLink from "@/components/Common/CustomLink";
import CustomImage from "@/components/Common/CustomImage";

const SellerProfile = () => {
  const params = useParams();
  const slug = params?.slug;
  const [seller, setSeller] = useState(null);
  const [items, setItems] = useState([]);
  const [ratingCount, setRatingCount] = useState(0);
  const [isLoading, setIsLoading] = useState(true);

  const sellerId = useMemo(() => parseSellerIdFromSlug(slug), [slug]);

  useEffect(() => {
    if (!slug) return;
    fetchSeller();
  }, [slug]);

  const fetchSeller = async () => {
    try {
      setIsLoading(true);
      const sellerParams = /^\d+$/.test(String(slug))
        ? { id: sellerId }
        : { slug: String(slug) };

      const res = await getSellerApi.getSeller(sellerParams);
      if (res?.data?.error === false) {
        const data = res?.data?.data;
        setSeller(data?.seller);
        setRatingCount(data?.ratings?.total ?? data?.ratings?.data?.length ?? 0);

        if (data?.seller?.id) {
          const itemsRes = await getItemApi.getItem({
            user_id: data.seller.id,
            page: 1,
          });
          if (itemsRes?.data?.error === false) {
            setItems(itemsRes?.data?.data?.data ?? []);
          }
        }
      } else {
        toast.error(res?.data?.message || t("somethingWentWrong"));
      }
    } catch (error) {
      console.log(error);
      toast.error(t("somethingWentWrong"));
    } finally {
      setIsLoading(false);
    }
  };

  if (isLoading) {
    return (
      <div className="container py-10 flex justify-center">
        <Loader />
      </div>
    );
  }

  if (!seller) {
    return (
      <div className="container py-10 text-center text-muted-foreground">
        {t("sellerNotFound")}
      </div>
    );
  }

  return (
    <div className="container py-6 space-y-6">
      <SellerDetailCard
        seller={seller}
        ratingCount={ratingCount}
        setSeller={setSeller}
      />

      {items.length > 0 && (
        <div className="space-y-4">
          <h2 className="text-xl font-bold">{t("liveAds")}</h2>
          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
            {items.map((item) => (
              <CustomLink
                key={item.id}
                href={`/ad-details/${item.slug}`}
                className="rounded-lg border overflow-hidden"
              >
                <CustomImage
                  src={item.image}
                  alt={item.translated_name || item.name}
                  width={300}
                  height={200}
                  className="w-full aspect-[4/3] object-cover"
                />
                <div className="p-3">
                  <p className="font-medium line-clamp-2">
                    {item.translated_name || item.name}
                  </p>
                </div>
              </CustomLink>
            ))}
          </div>
        </div>
      )}
    </div>
  );
};

export default SellerProfile;
