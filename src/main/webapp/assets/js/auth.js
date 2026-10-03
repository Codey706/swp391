document.addEventListener('DOMContentLoaded', function () {
  const togglePassword = document.getElementById('togglePassword');
  const passwordInput = document.getElementById('password');
  const eyeIcon = document.getElementById('eyeIcon');

  if (togglePassword && passwordInput && eyeIcon) {
    togglePassword.addEventListener('click', function () {
      const isPassword = passwordInput.getAttribute('type') === 'password';
      passwordInput.setAttribute('type', isPassword ? 'text' : 'password');
      eyeIcon.className = isPassword ? 'bi bi-eye-slash' : 'bi bi-eye';
    });
  }

  const themeToggleBtn = document.getElementById('themeToggleBtn');
  const modeIcon = document.getElementById('modeIcon');
  const modeText = document.getElementById('modeText');
  let isDark = false;

  if (themeToggleBtn) {
    themeToggleBtn.addEventListener('click', function () {
      isDark = !isDark;
      const card = document.querySelector('.auth-card');
      const title = document.querySelector('.auth-title');
      const divider = document.querySelector('.divider-text');
      if (isDark) {
        modeIcon.className = 'bi bi-moon-stars text-primary';
        modeText.textContent = 'Chế độ tối';
        document.body.style.backgroundColor = '#161c24';
        if (card) {
          card.style.backgroundColor = '#202832';
          card.style.borderColor = 'rgba(255,255,255,0.1)';
        }
        if (title) title.style.color = '#ffffff';
        document.querySelectorAll('.form-label-custom').forEach(function (l) { l.style.color = '#ffffff'; });
        if (divider) {
          divider.style.backgroundColor = '#202832';
          divider.style.color = '#cbd5e1';
        }
      } else {
        modeIcon.className = 'bi bi-brightness-high text-warning-emphasis';
        modeText.textContent = 'Chế độ sáng';
        document.body.style.backgroundColor = 'var(--bg-canvas)';
        if (card) {
          card.style.backgroundColor = 'var(--card-bg)';
          card.style.borderColor = 'rgba(224, 191, 182, 0.35)';
        }
        if (title) title.style.color = 'var(--text-main)';
        document.querySelectorAll('.form-label-custom').forEach(function (l) { l.style.color = 'var(--text-main)'; });
        if (divider) {
          divider.style.backgroundColor = 'var(--card-bg)';
          divider.style.color = '#8d7169';
        }
      }
    });
  }

  const googleBtn = document.getElementById('googleLoginBtn');
  const alertContainer = document.getElementById('alertContainer');
  const alertMessage = document.getElementById('alertMessage');
  if (googleBtn && alertContainer && alertMessage) {
    googleBtn.addEventListener('click', function () {
      alertContainer.className = 'alert alert-info py-2 px-3 mb-3 small';
      alertMessage.textContent = 'Đăng nhập Google sẽ được tích hợp ở bước sau.';
    });
  }
});
