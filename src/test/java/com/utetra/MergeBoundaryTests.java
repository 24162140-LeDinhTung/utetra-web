package com.utetra;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.Mockito.*;
import com.utetra.service.OfferEvents;
import com.utetra.service.impl.LocalStorageServiceImpl;
import com.utetra.service.impl.WalletServiceImpl;
import com.utetra.repository.WalletTransactionRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.util.ReflectionTestUtils;
import java.nio.file.Path;

class MergeBoundaryTests {
  @TempDir Path directory;

  @Test void uploadsStayLocalAndRejectActiveContent() {
    var storage = new LocalStorageServiceImpl();
    ReflectionTestUtils.setField(storage, "uploadDir", directory.toString());
    ReflectionTestUtils.setField(storage, "urlPrefix", "/uploads");
    storage.init();
    var url = storage.uploadFile(new MockMultipartFile("file", "photo.jpg", "image/jpeg", new byte[]{1,2}), "utetra/reviews/7");
    var file = directory.resolve(url.substring("/uploads/".length()));
    assertThat(file).exists();
    storage.deleteFile(url);assertThat(file).doesNotExist();
    assertThatThrownBy(() -> storage.uploadFile(new MockMultipartFile("file", "evil.html", "text/html", new byte[]{1}), "utetra/reviews/7"))
        .isInstanceOf(IllegalArgumentException.class);
  }

  @Test void walletHistoryQueriesOnlyRequestedWallet() {
    var repository = mock(WalletTransactionRepository.class);
    var service = new WalletServiceImpl();
    ReflectionTestUtils.setField(service, "transactionRepository", repository);
    service.getTransactionHistory(7L);
    verify(repository).findByWalletId(7L);
    verify(repository, never()).findAll();
  }

  @Test void offerNotificationsUseShopScopedTopicAndBrokerFailureDoesNotFailCommittedWork() {
    var broker = mock(SimpMessagingTemplate.class);
    var events = new OfferEvents(broker);
    var change = new OfferEvents.Changed(9L);
    events.changed(change);
    verify(broker).convertAndSend("/topic/shop/9/offers", change);
    doThrow(new IllegalStateException("offline")).when(broker).convertAndSend("/topic/shop/9/offers", change);
    assertThatCode(() -> events.changed(change)).doesNotThrowAnyException();
  }
}
