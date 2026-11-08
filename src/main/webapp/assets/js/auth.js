document.addEventListener('DOMContentLoaded', function () {
  const togglePassword = document.getElementById('togglePassword');
  const passwordInput = document.getElementById('password');
  const eyeIcon = document.getElementById('eyeIcon');

  if (togglePassword && passwordInput && eyeIcon) {
    togglePassword.addEventListener('click', function () {
      const isPassword = passwordInput.getAttribute('type') === 'password';
      passwordInput.setAttribute('type', isPassword ? 'text' : 'password');
      eyeIcon.className = isPassword ? 'ph ph-eye-slash' : 'ph ph-eye';
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
        modeIcon.className = 'ph ph-moon-stars text-primary';
        modeText.textContent = 'Chế độ tối';
        document.body.style.backgroundColor = '#1f1f22';
        if (card) {
          card.style.backgroundColor = '#1f1f22';
          card.style.borderColor = 'rgba(255,255,255,0.1)';
        }
        if (title) title.style.color = '#ffffff';
        document.querySelectorAll('.form-label-custom').forEach(function (l) { l.style.color = '#ffffff'; });
        if (divider) {
          divider.style.backgroundColor = '#1f1f22';
          divider.style.color = '#d4d4d8';
        }
      } else {
        modeIcon.className = 'ph ph-sun text-warning-emphasis';
        modeText.textContent = 'Chế độ sáng';
        document.body.style.backgroundColor = 'var(--bg-canvas)';
        if (card) {
          card.style.backgroundColor = 'var(--card-bg)';
          card.style.borderColor = 'rgba(245, 194, 185, 0.35)';
        }
        if (title) title.style.color = 'var(--text-main)';
        document.querySelectorAll('.form-label-custom').forEach(function (l) { l.style.color = 'var(--text-main)'; });
        if (divider) {
          divider.style.backgroundColor = 'var(--card-bg)';
          divider.style.color = '#77777e';
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
