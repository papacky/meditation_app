// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// simple_calendarの月タイトルを削除（ナビゲーションは保持）
document.addEventListener('DOMContentLoaded', function() {
  hideCalendarTitle();
});

// Turbo使用時のページ遷移後にも実行
document.addEventListener('turbo:load', function() {
  hideCalendarTitle();
});

function hideCalendarTitle() {
  const calendarHeading = document.querySelector('.simple-calendar .calendar-heading');
  if (calendarHeading) {
    // ナビゲーションリンク（a要素）以外のテキストノードを削除
    const childNodes = Array.from(calendarHeading.childNodes);
    childNodes.forEach(node => {
      if (node.nodeType === Node.TEXT_NODE && node.textContent.trim() !== '') {
        node.textContent = '';
      } else if (node.nodeType === Node.ELEMENT_NODE && node.tagName !== 'A') {
        // h2やその他の要素のテキストを削除（リンク以外）
        if (node.textContent && !node.querySelector('a')) {
          node.style.display = 'none';
        }
      }
    });
  }
}
