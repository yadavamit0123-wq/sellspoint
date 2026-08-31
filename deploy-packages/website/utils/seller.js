/** Build seller profile path — supports slug (saaho-mori-1277) or numeric id fallback. */
export function buildSellerSlug(user) {
  if (!user?.id) return null;
  if (user.slug) return user.slug;

  const base = String(user.name || "user")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");

  return `${base || "user"}-${user.id}`;
}

export function getSellerProfilePath(user) {
  if (!user?.id) return "/seller";
  return `/seller/${buildSellerSlug(user)}`;
}

/** Parse trailing numeric id from seller slug; plain numeric ids still work. */
export function parseSellerIdFromSlug(slug) {
  if (!slug) return null;
  const value = decodeURIComponent(String(slug).trim());
  if (/^\d+$/.test(value)) return parseInt(value, 10);
  const match = value.match(/-(\d+)$/);
  return match ? parseInt(match[1], 10) : null;
}
