package com.albatross.api;

import com.albatross.api.config.AppProperties;
import com.albatross.api.config.AwsProperties;
import com.albatross.api.exception.ApiException;
import com.albatross.api.model.ImageOptions;
import com.albatross.api.security.SecurityService;
import com.albatross.api.v1.flow.model.Attachment;
import com.albatross.api.v1.flow.services.AttachmentService;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.util.UriComponentsBuilder;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.net.URI;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class PublicAttachmentService {

  private final SecurityService securityService;
  private final AttachmentService attachmentService;
  private final AwsProperties awsProperties;
  private final AppProperties appProperties;

  public Optional<Attachment> loadPublicAttachment(Long attachmentId, UUID uuid) {
    return attachmentService
        .getAttachmentForUuid(attachmentId)
        .filter(attachment -> attachment.getUuid().equals(uuid));
  }

  public List<Attachment> loadMaintenanceAttachments() {
    return attachmentService.getAttachmentsByTypeWithoutSource(938L);
  }

  public Optional<URI> findAttachmentURIByUUID(
      @NonNull UUID uuid, ImageOptions imageOptions) {
    return attachmentService
        .findAttachmentByUUID(uuid)
        .map(attachment -> getRedirectURI(attachment, imageOptions));
  }

  private URI getRedirectURI(
      @NonNull Attachment attachment, ImageOptions imageOptions) {
    final boolean isProxyable =
        attachment.getFileExtension().toLowerCase().matches("(jpe?g|png|gif|webp)");

    final AppProperties.ImageProxyProperties imageProxy = appProperties.getImageProxy();

    if (imageProxy.isImageProxyEnabled() && isProxyable) {
      final String s3Url =
          String.format("s3://%s/%s", awsProperties.getStorageBucket(), attachment.getS3Key());
      String encodedUrl = Base64.getUrlEncoder().withoutPadding().encodeToString(s3Url.getBytes());
      String path = String.format("%s/%s", imageOptions.getParams(), encodedUrl);
      String signature = generateUrlSignatureForImgProxy(path);

      return UriComponentsBuilder.fromUri(imageProxy.getUrl())
          .pathSegment(signature, path)
          .build()
          .toUri();
    }
    return attachmentService.getPresignedUrl(attachment, false).orElse(null);
  }

  private String generateUrlSignatureForImgProxy(String path){

    try {

      final AppProperties.ImageProxyProperties imageProxy = appProperties.getImageProxy();

      if (imageProxy.isURLSignatureCheckingEnabled()){
        final String hmacSHA256Algorithm = "HmacSHA256";
        final Mac hmac = Mac.getInstance(hmacSHA256Algorithm);
        final byte[] key = hexStringToByteArray( imageProxy.getKey());
        final byte[] salt = hexStringToByteArray(imageProxy.getSalt());
        final SecretKeySpec secretKey = new SecretKeySpec(key, hmacSHA256Algorithm);

        hmac.init(secretKey);
        hmac.update(salt);

        return Base64.getUrlEncoder().withoutPadding().encodeToString(hmac.doFinal(path.getBytes()));
      }

      return "insecure";

    } catch (NoSuchAlgorithmException | InvalidKeyException e) {
      throw new ApiException(e);
    }
  }

  private byte[] hexStringToByteArray(String hex){
    if (hex.length() % 2 != 0)
      throw new IllegalArgumentException("Even-length string required");
    byte[] res = new byte[hex.length() / 2];
    for (int i = 0; i < res.length; i++) {
      res[i]=(byte)((Character.digit(hex.charAt(i * 2), 16) << 4) | (Character.digit(hex.charAt(i * 2 + 1), 16)));
    }
    return res;
  }
}
