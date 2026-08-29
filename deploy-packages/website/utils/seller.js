/** Build seller profile path — supports slug (saaho-mori-1277) or numeric id fallback. */
export function getSellerProfilePath(user) {
  if (!user?.id) return "/seller";
  return `/seller/${user.slug || user.id}`;
}

/** Parse trailing numeric id from seller slug; plain numeric ids still work. */
export function parseSellerIdFromSlug(slug) {
  if (!slug) return null;
  const value = decodeURIComponent(String(slug).trim());
  if (/^\d+$/.test(value)) return parseInt(value, 10);
  const match = value.match(/-(\d+)$/);
  return match ? parseInt(match[1], 10) : null;
}
