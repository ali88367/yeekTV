/// Fixes S3 URL format issues
String fixS3UrlFormat(String url) {
  if (url.isEmpty) return url;

  try {
    // Problematic format (Safari/iOS SSL strict):
    // yeek.tv.s3.eu-north-1.amazonaws.com -> should be s3.eu-north-1.amazonaws.com/yeek.tv/
    const problematicDomain = "yeek.tv.s3.eu-north-1.amazonaws.com";
    const problematicDomainEncoded = "yeek%2Etv%2Es3.eu-north-1.amazonaws.com";
    const problematicDomainDoubleEncoded =
        "yeek%252Etv%252Es3.eu-north-1.amazonaws.com";

    final containsProblem =
        url.contains(problematicDomain) ||
        url.contains(problematicDomainEncoded) ||
        url.contains(problematicDomainDoubleEncoded);

    if (!containsProblem) {
      // Already correct format or different URL, only ensure https.
      if (url.startsWith("http://")) {
        return url.replaceFirst("http://", "https://");
      }
      return url;
    }

    String? path;

    // Direct match (most reliable)
    final domainIndex = url.indexOf("$problematicDomain/");
    if (domainIndex != -1) {
      path = url.substring(domainIndex + problematicDomain.length + 1);
    } else {
      // Encoded domain
      final encodedIndex = url.indexOf("$problematicDomainEncoded/");
      if (encodedIndex != -1) {
        path = url.substring(
          encodedIndex + problematicDomainEncoded.length + 1,
        );
      } else {
        // Double-encoded domain
        final doubleEncodedIndex = url.indexOf(
          "$problematicDomainDoubleEncoded/",
        );
        if (doubleEncodedIndex != -1) {
          path = url.substring(
            doubleEncodedIndex + problematicDomainDoubleEncoded.length + 1,
          );
        } else {
          // Regex fallback
          final regex = RegExp(
            r"yeek\.tv\.s3\.eu-north-1\.amazonaws\.com\/(.+)$",
            caseSensitive: false,
          );
          final match = regex.firstMatch(url);
          if (match != null && match.groupCount >= 1) {
            path = match.group(1);
          }
        }
      }
    }

    if (path != null && path.isNotEmpty) {
      return "https://s3.eu-north-1.amazonaws.com/yeek.tv/$path";
    }

    // If URL already has correct format, return as-is
    if (url.startsWith("https://s3.eu-north-1.amazonaws.com/yeek.tv/") ||
        url.startsWith("https://yeek-tv.s3.eu-north-1.amazonaws.com/")) {
      return url;
    }

    // Ensure HTTPS
    if (url.startsWith("http://")) {
      return url.replaceFirst("http://", "https://");
    }
    return url;
  } catch (_) {
    // If anything goes wrong, at least enforce https.
    if (url.startsWith("http://")) {
      return url.replaceFirst("http://", "https://");
    }
    return url;
  }
}
