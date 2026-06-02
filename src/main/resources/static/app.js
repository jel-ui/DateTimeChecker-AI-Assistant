(function startApplication() {
  "use strict";

  const fields = ["day", "month", "year", "hour", "minute", "second"];
  const form = document.querySelector("#dateTimeForm");
  const emptyState = document.querySelector("#emptyState");
  const resultContent = document.querySelector("#resultContent");
  const resultCard = document.querySelector("#resultCard");
  const statusIcon = document.querySelector("#statusIcon");
  const resultTitle = document.querySelector("#resultTitle");
  const resultMessage = document.querySelector("#resultMessage");
  const errorList = document.querySelector("#errorList");
  const detailGrid = document.querySelector("#detailGrid");
  const recentSection = document.querySelector("#recentSection");
  const recentList = document.querySelector("#recentList");
  const installButton = document.querySelector("#installButton");
  const historyKey = "date-time-checker-history";
  let deferredInstallPrompt;

  const icons = {
    valid: '<svg viewBox="0 0 24 24"><path d="m5 12 4 4L19 6"/></svg>',
    invalid: '<svg viewBox="0 0 24 24"><path d="M12 8v4m0 4h.01"/><circle cx="12" cy="12" r="9"/></svg>',
  };

  function fieldValues() {
    return {
      day: document.querySelector("#day").value,
      month: document.querySelector("#month").value,
      year: document.querySelector("#year").value,
      hour: document.querySelector("#hour").value,
      minute: document.querySelector("#minute").value,
      second: document.querySelector("#second").value,
      timezoneOffsetMinutes: -new Date().getTimezoneOffset(),
    };
  }

  function setFields(date) {
    const values = {
      day: date.getDate(),
      month: date.getMonth() + 1,
      year: date.getFullYear(),
      hour: date.getHours(),
      minute: date.getMinutes(),
      second: date.getSeconds(),
    };
    fields.forEach((field) => {
      document.querySelector(`#${field}`).value = values[field];
    });
  }

  function makeDetail(label, value) {
    const wrapper = document.createElement("div");
    const term = document.createElement("dt");
    const description = document.createElement("dd");
    term.textContent = label;
    description.textContent = value;
    wrapper.append(term, description);
    return wrapper;
  }

  function formatDisplay(parts) {
    return `${String(parts.day).padStart(2, "0")}/${String(parts.month).padStart(2, "0")}/${parts.year} ${String(parts.hour).padStart(2, "0")}:${String(parts.minute).padStart(2, "0")}:${String(parts.second).padStart(2, "0")}`;
  }

  async function checkDateTime(values) {
    if (window.location.protocol === "file:") {
      throw new Error("Vui lòng chạy run.bat và mở http://localhost:4173 để sử dụng ứng dụng.");
    }

    const response = await fetch("/api/datetime/check", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(values),
    });
    if (!response.ok) throw new Error("Không thể kết nối đến máy chủ.");
    return response.json();
  }

  function renderError(error) {
    const message = error && error.message ? error.message : "Không thể kết nối đến máy chủ.";
    renderResult({ valid: false, errors: [message] });
  }

  async function validateCurrentFields() {
    try {
      renderResult(await checkDateTime(fieldValues()));
    } catch (error) {
      renderError(error);
    }
  }

  function renderResult(result) {
    emptyState.hidden = true;
    resultContent.hidden = false;
    statusIcon.classList.toggle("invalid", !result.valid);
    statusIcon.innerHTML = result.valid ? icons.valid : icons.invalid;
    errorList.replaceChildren();
    detailGrid.replaceChildren();

    if (!result.valid) {
      resultTitle.textContent = "Ngày giờ không hợp lệ";
      resultMessage.textContent = "Vui lòng kiểm tra lại dữ liệu bên dưới.";
      result.errors.forEach((error) => {
        const item = document.createElement("li");
        item.textContent = error;
        errorList.append(item);
      });
      errorList.hidden = false;
      return;
    }

    const details = result.details;
    resultTitle.textContent = "Ngày giờ hợp lệ";
    resultMessage.textContent = `${details.display} là một thời điểm hợp lệ trên thiết bị của bạn.`;
    errorList.hidden = true;
    [
      ["Thứ trong tuần", details.weekday],
      ["Thời điểm", details.period],
      ["Năm nhuận", details.leapYear],
      ["Số ngày trong tháng", details.monthDays],
      ["Múi giờ", details.offset],
      ["Unix timestamp", details.timestamp],
    ].forEach(([label, value]) => detailGrid.append(makeDetail(label, value)));
    remember(result.parts);
  }

  function getHistory() {
    try {
      return JSON.parse(localStorage.getItem(historyKey)) || [];
    } catch {
      return [];
    }
  }

  function remember(parts) {
    const key = formatDisplay(parts);
    const history = getHistory().filter((item) => formatDisplay(item) !== key);
    history.unshift(parts);
    localStorage.setItem(historyKey, JSON.stringify(history.slice(0, 4)));
    renderHistory();
  }

  function renderHistory() {
    const history = getHistory();
    recentList.replaceChildren();
    recentSection.hidden = history.length === 0;
    history.forEach((parts) => {
      const button = document.createElement("button");
      const dateLabel = document.createElement("strong");
      const timeLabel = document.createElement("small");
      button.type = "button";
      button.className = "recent-item";
      dateLabel.textContent = `${String(parts.day).padStart(2, "0")}/${String(parts.month).padStart(2, "0")}/${parts.year}`;
      timeLabel.textContent = `${String(parts.hour).padStart(2, "0")}:${String(parts.minute).padStart(2, "0")}:${String(parts.second).padStart(2, "0")}`;
      button.append(dateLabel, timeLabel);
      button.addEventListener("click", async () => {
        fields.forEach((field) => {
          document.querySelector(`#${field}`).value = parts[field];
        });
        try {
          renderResult(await checkDateTime({
            day: parts.day,
            month: parts.month,
            year: parts.year,
            hour: parts.hour,
            minute: parts.minute,
            second: parts.second,
            timezoneOffsetMinutes: -new Date().getTimezoneOffset(),
          }));
        } catch (error) {
          renderError(error);
        }
        resultCard.scrollIntoView({ behavior: "smooth", block: "center" });
      });
      recentList.append(button);
    });
  }

  function updateClock() {
    const now = new Date();
    document.querySelector("#liveTime").textContent = now.toLocaleTimeString("vi-VN");
    document.querySelector("#liveDate").textContent = now.toLocaleDateString("vi-VN", {
      weekday: "long",
      day: "2-digit",
      month: "2-digit",
      year: "numeric",
    });
  }

  form.addEventListener("submit", async (event) => {
    event.preventDefault();
    await validateCurrentFields();
  });

  document.querySelector("#nowButton").addEventListener("click", async () => {
    setFields(new Date());
    await validateCurrentFields();
  });

  document.querySelector("#clearButton").addEventListener("click", () => {
    form.reset();
    emptyState.hidden = false;
    resultContent.hidden = true;
  });

  document.querySelector("#clearRecentButton").addEventListener("click", () => {
    localStorage.removeItem(historyKey);
    renderHistory();
  });

  document.querySelector("#themeButton").addEventListener("click", () => {
    const nextTheme = document.documentElement.dataset.theme === "dark" ? "light" : "dark";
    document.documentElement.dataset.theme = nextTheme;
    localStorage.setItem("date-time-checker-theme", nextTheme);
  });

  window.addEventListener("beforeinstallprompt", (event) => {
    event.preventDefault();
    deferredInstallPrompt = event;
    installButton.hidden = false;
  });

  installButton.addEventListener("click", async () => {
    if (!deferredInstallPrompt) return;
    deferredInstallPrompt.prompt();
    await deferredInstallPrompt.userChoice;
    deferredInstallPrompt = null;
    installButton.hidden = true;
  });

  window.addEventListener("appinstalled", () => {
    deferredInstallPrompt = null;
    installButton.hidden = true;
  });

  if ("serviceWorker" in navigator) {
    window.addEventListener("load", () => navigator.serviceWorker.register("service-worker.js"));
  }

  document.documentElement.dataset.theme = localStorage.getItem("date-time-checker-theme") || "light";
  document.querySelector("#timezoneLabel").textContent = Intl.DateTimeFormat().resolvedOptions().timeZone;
  setFields(new Date());
  updateClock();
  setInterval(updateClock, 1000);
  renderHistory();
})();
