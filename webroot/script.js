const MODDIR = `/data/adb/modules/playintegrity/webroot/common_scripts`;
const PROP = `/data/adb/modules/playintegrity/module.prop`;
let modalBackdrop = document.getElementById("modal-backdrop");
let modalTitle = document.getElementById("modal-title");
let modalOutput = document.getElementById("modal-output");
let modalClose = document.getElementById("modal-close");
let modalContent = document.getElementById("modal-content");

function runShell(command) {
  if (!command) return Promise.reject(new Error("No command provided"));
  if (typeof ksu !== "object" || typeof ksu.exec !== "function") {
    return Promise.reject(new Error("KernelSU JavaScript API not available."));
  }
  const cb = `cb_${Date.now()}_${Math.floor(Math.random()*10000)}`;
  return new Promise((resolve, reject) => {
    window[cb] = (code, stdout, stderr) => {
      try {
        const out = String(stdout || "");
        const err = String(stderr || "");
        if (Number(code) === 0) resolve(out.replace(/\r/g, ""));
        else reject(new Error(err || out || "Shell command failed"));
      } finally {
        try { delete window[cb]; } catch(e){}
      }
    };
    try {
      ksu.exec(command, "{}", cb);
    } catch (e) {
      try { delete window[cb]; } catch(e){}
      reject(e);
    }
  });
}

function popup(msg, type) {
  document.querySelectorAll(".webui-popup").forEach(el => el.remove());
  const n = document.createElement("div");
  n.className = "webui-popup";
  n.textContent = msg || "";

  const themeAccent = getComputedStyle(document.documentElement)
    .getPropertyValue("--accent")
    .trim();

  const colorMap = {
    error: getComputedStyle(document.documentElement).getPropertyValue("--error").trim(),
    success: getComputedStyle(document.documentElement).getPropertyValue("--meowna").trim(),
    info: "#1565c0",
    warn: "#ff8f00"
  };
  const bg = type && colorMap[type] ? colorMap[type] : themeAccent;

  Object.assign(n.style, {
    position: "fixed",
    top: "-70px",
    left: "50%",
    transform: "translateX(-50%)",
    background: bg,
    color: "#fff",
    padding: "0.8rem 1.2rem",
    borderRadius: "8px",
    boxShadow: "0 6px 18px rgba(0,0,0,0.35)",
    fontSize: "0.95rem",
    fontWeight: "600",
    zIndex: "99999",
    transition: "top 0.36s ease, opacity 0.36s ease",
    opacity: "0",
    whiteSpace: "nowrap",
    overflow: "hidden",
    textOverflow: "ellipsis",
    maxWidth: "90vw"
  });

  document.body.appendChild(n);
  requestAnimationFrame(() => {
    n.style.top = "20px";
    n.style.opacity = "1";
  });
  setTimeout(() => {
    n.style.top = "-70px";
    n.style.opacity = "0";
    setTimeout(() => n.remove(), 420);
  }, 2500);
}

function openModal(title, content, fullscreen) {
  modalBackdrop = modalBackdrop || document.getElementById("modal-backdrop");
  modalTitle = modalTitle || document.getElementById("modal-title");
  modalOutput = modalOutput || document.getElementById("modal-output");
  modalContent = modalContent || document.getElementById("modal-content");
  if (modalTitle) modalTitle.textContent = title || "";
  if (modalOutput) modalOutput.innerHTML = content ?? "Loading...";
  if (modalBackdrop) modalBackdrop.classList.remove("hidden");
  if (fullscreen) {
    modalBackdrop?.classList.add("fullscreen");
    modalContent?.classList.add("fullscreen");
    modalOutput?.classList.add("fullscreen");
  } else {
    modalBackdrop?.classList.remove("fullscreen");
    modalContent?.classList.remove("fullscreen");
    modalOutput?.classList.remove("fullscreen");
  }
}

function closeModal() {
  modalBackdrop = modalBackdrop || document.getElementById("modal-backdrop");
  modalBackdrop?.classList.add("hidden");
}

async function getModuleName() {
  try {
    const name = await runShell(`grep '^name=' ${PROP} | cut -d= -f2`);
    const t = (name || "").trim() || "IntegrityBox";
    const el = document.getElementById("module-name");
    if (el) el.textContent = t;
    document.title = t;
  } catch {
    const el = document.getElementById("module-name");
    if (el) el.textContent = "IntegrityBox";
    document.title = "IntegrityBox";
  }
}

async function updateDashboard() {
  const statusWhitelist = document.getElementById("status-whitelist");
  const statusGms = document.getElementById("status-gms");
  const statusSusfs = document.getElementById("status-susfs");
  try {
    await runShell("[ -f /data/adb/nohello/whitelist ] || [ -f /data/adb/shamiko/whitelist ]");
    if (statusWhitelist) { statusWhitelist.textContent = "Enabled"; statusWhitelist.className = "status-indicator enabled"; }
  } catch {
    if (statusWhitelist) { statusWhitelist.textContent = "Disabled"; statusWhitelist.className = "status-indicator disabled"; }
  }
  try {
    const gmsProp = await runShell("getprop persist.sys.pihooks.disable.gms_props || echo ''");
    const trimmed = (gmsProp || "").trim();
    if (statusGms) { statusGms.textContent = trimmed === "true" ? "Disabled" : "Enabled"; statusGms.className = "status-indicator enabled"; }
  } catch {
    if (statusGms) { statusGms.textContent = "Unknown"; statusGms.className = "status-indicator"; }
  }
  try {
    await runShell("[ -d /data/adb/modules/susfs4ksu ]");
    if (statusSusfs) { statusSusfs.textContent = "Detected"; statusSusfs.className = "status-indicator enabled"; }
  } catch {
    if (statusSusfs) { statusSusfs.textContent = "N/A"; statusSusfs.className = "status-indicator disabled"; }
  }
}

async function _loadLangModule(lang) {
  try {
    const mod = await import(`./lang/${lang}.js`);
    return { translations: mod.translations ?? (mod.default && mod.default.translations) ?? {}, buttonGroups: mod.buttonGroups ?? (mod.default && mod.default.buttonGroups) ?? {}, buttonOrder: mod.buttonOrder ?? (mod.default && mod.default.buttonOrder) ?? [] };
  } catch (e) {
    return new Promise((resolve) => {
      const prev = document.getElementById("lang-script");
      if (prev) prev.remove();
      window.translations = undefined;
      window.buttonGroups = undefined;
      window.buttonOrder = undefined;
      const s = document.createElement("script");
      s.id = "lang-script";
      s.src = `lang/${lang}.js`;
      s.onload = () => setTimeout(() => resolve({ translations: window.translations ?? {}, buttonGroups: window.buttonGroups ?? {}, buttonOrder: window.buttonOrder ?? [] }), 60);
      s.onerror = () => resolve({ translations: {}, buttonGroups: {}, buttonOrder: [] });
      document.head.appendChild(s);
    });
  }
}

function _getLabelFromTranslations(translations, lang, index, scriptName, fallback) {
  if (!translations) return fallback;
  if (Array.isArray(translations) && translations[index]) return translations[index];
  if (typeof translations === "object") {
    if (translations[lang] && Array.isArray(translations[lang]) && translations[lang][index]) return translations[lang][index];
    if (translations[scriptName]) return translations[scriptName];
    if (translations[index]) return translations[index];
  }
  return fallback;
}

function getButtonText(btn) {
  let text = "";
  btn.childNodes.forEach(n => {
    if (n.nodeType === Node.TEXT_NODE) text += n.textContent;
    else if (n.nodeType === 1 && !n.classList.contains("icon") && !n.classList.contains("spinner")) text += n.textContent || "";
  });
  return (text || "").trim();
}

function setButtonLabel(btn, label) {
  const icon = btn.querySelector(".icon");
  const spinner = btn.querySelector(".spinner");
  Array.from(btn.childNodes).forEach(n => { if (n.nodeType === Node.TEXT_NODE) n.remove(); });
  const textNode = document.createTextNode(" " + label);
  if (icon && icon.parentNode) icon.parentNode.insertBefore(textNode, icon.nextSibling);
  else if (spinner && spinner.parentNode) spinner.parentNode.insertBefore(textNode, spinner);
  else btn.appendChild(textNode);
}

async function changeLanguage(lang) {
  if (!lang) lang = localStorage.getItem("lang") || "en";
  localStorage.setItem("lang", lang);
  document.documentElement.setAttribute("dir", (lang === "ar" || lang === "ur") ? "rtl" : "ltr");
  const { translations, buttonGroups, buttonOrder } = await _loadLangModule(lang);
  document.querySelectorAll(".group-title").forEach(title => {
    const originalKey = title.dataset.key || title.textContent.trim();
    if (!title.dataset.key) title.dataset.key = originalKey;
    let newTitle = null;
    if (buttonGroups && buttonGroups[originalKey]) {
      if (typeof buttonGroups[originalKey] === "string") newTitle = buttonGroups[originalKey];
      else if (buttonGroups[originalKey][lang]) newTitle = buttonGroups[originalKey][lang];
    }
    if (newTitle) title.textContent = newTitle;
  });
  const labelsArray = Array.isArray(translations) ? translations : (translations[lang] && Array.isArray(translations[lang]) ? translations[lang] : null);
  if (Array.isArray(buttonOrder) && buttonOrder.length > 0) {
    buttonOrder.forEach((scriptName, index) => {
      const btn = document.querySelector(`.btn[data-script='${scriptName}']`);
      if (!btn) return;
      if (!btn.dataset.origLabel) btn.dataset.origLabel = getButtonText(btn) || scriptName;
      const fallback = btn.dataset.origLabel || scriptName;
      const label = _getLabelFromTranslations(translations, lang, index, scriptName, labelsArray && labelsArray[index] ? labelsArray[index] : fallback);
      setButtonLabel(btn, label);
    });
  } else {
    const btns = Array.from(document.querySelectorAll(".btn"));
    btns.forEach((btn, index) => {
      const scriptName = btn.dataset.script;
      if (!btn.dataset.origLabel) btn.dataset.origLabel = getButtonText(btn) || scriptName;
      const fallback = btn.dataset.origLabel || scriptName;
      const label = _getLabelFromTranslations(translations, lang, index, scriptName, labelsArray && labelsArray[index] ? labelsArray[index] : fallback);
      setButtonLabel(btn, label);
    });
  }
  document.querySelectorAll("[data-i18n]").forEach(el => {
    const key = el.getAttribute("data-i18n");
    if (!key) return;
    if (translations && translations[key]) el.innerText = translations[key];
    else if (translations[lang] && translations[lang][key]) el.innerText = translations[lang][key];
  });
}

const SCRIPT_POPUPS = {
  "kill.sh": { success: "Process Killed Successfully", type: "info" },
  "vending.sh": { success: "Open playstore & Check/FIX", type: "info" },  
  "user.sh": { success: "I've added all user apps", type: "info" },
  "sus.sh": { start: " ", success: "Make it SUS🥷", type: "info" },
  "stop.sh": { success: "Switched to Blacklist Mode", type: "info" },
  "start.sh": { success: "Switched to Whitelist Mode", type: "info" },
  "spoof.sh": { success: "Applied", type: "info" },
  "resetprop.sh": { success: "Done, Reopen detector to check", type: "info" },
  "piffork": { start: "All changes will be applied immediately", type: "info" },
  "pif.sh": { success: "Done!", type: "info" },
  "patch.sh": { success: "Patch Status : ✅ Spoofed", type: "info" },
  "key.sh": { success: "Keybox has been updated✅", type: "info" },
  "issue.sh": { success: "Report your problem here", type: "info" },
  "app.sh": { start: " ", success: "Detection Complete", type: "info" },
  "meowdump.sh": { success: "Redirected to Telegram", type: "info" },
  "support": { start: "Become a Supporter", type: "info" },
  "boot_hash.sh": { success: "Boot hash operation complete", type: "success" }
};

document.addEventListener("DOMContentLoaded", async () => {
  modalBackdrop = document.getElementById("modal-backdrop");
  modalTitle = document.getElementById("modal-title");
  modalOutput = document.getElementById("modal-output");
  modalClose = document.getElementById("modal-close");
  modalContent = document.getElementById("modal-content");
  await getModuleName();
  await updateDashboard();

  document.querySelectorAll(".btn").forEach((btn) => {
    if (btn._handlerAttached) return;
    btn._handlerAttached = true;
    if (!btn.dataset.origLabel) btn.dataset.origLabel = getButtonText(btn) || (btn.dataset.script || "");
    btn.addEventListener("click", async () => {
      const script = btn.dataset.script;
      const type = btn.dataset.type;
      const command = script ? `sh ${MODDIR}/${script}` : null;
      btn.classList.add("loading");
      const mapping = SCRIPT_POPUPS[script] || SCRIPT_POPUPS[script.replace(/\.sh$/,'')] || { start: `Running ${btn.dataset.origLabel || script}`, success: `Finished ${btn.dataset.origLabel || script}`, type: "info" };
      try {
        popup(mapping.start, mapping.type);
        if (type === "scanner") {
          openModal(btn.dataset.origLabel || btn.innerText.trim(), "Running scan...", true);
          try {
            const output = await runShell(command);
            modalOutput.innerHTML = (output || "Script executed with no output.").replace(/\n/g, "<br>");
            popup(mapping.success, "success");
          } catch (err) {
            modalOutput.innerText = `Error executing script:\n\n${err.message || String(err)}`;
            popup(`Error: ${err.message || String(err)}`, "error");
          } finally {
          }
        } else if (type === "hash") {
          const output = await runShell(`sh ${MODDIR}/boot_hash.sh get`).catch(()=>"");
          const lines = (output || "").trim().split(/\r?\n/);
          const saved = (lines[1] || "").trim();
          const content = `<div style="display:flex;flex-direction:column;gap:1rem"><label>Copy your Verified Boot Hash from key attestation or native detector app and</label><label>Paste it here:</label><input id="new-hash" type="text" value="${saved}" placeholder="abcdef1234..." style="width:100%;padding:0.5rem;font-size:0.9rem;border-radius:8px;border:1px solid var(--border-color);background:var(--panel-bg);color:var(--fg);" /><div style="display:flex;gap:1rem;flex-wrap:wrap;"><button class="btn" id="apply-hash"><span class="icon material-symbols-outlined">done</span>Apply</button><button class="btn" id="reset-hash"><span class="icon material-symbols-outlined">restart_alt</span>Reset</button></div></div>`;
          openModal("Set Verified Boot Hash", content, true);
          setTimeout(() => {
            document.getElementById("apply-hash")?.addEventListener("click", async () => {
              const hash = (document.getElementById("new-hash")?.value || "").trim();
              const cmd = hash ? `sh ${MODDIR}/boot_hash.sh set ${hash}` : `sh ${MODDIR}/boot_hash.sh clear`;
              try {
                await runShell(cmd);
                popup("Boot hash applied ✅", "success");
              } catch {
                popup("SusFS dir not found ❌", "error");
              } finally {
                await runShell(`sh ${MODDIR}/resethash.sh clear`).catch(()=>{});
                closeModal();
              }
            });
            document.getElementById("reset-hash")?.addEventListener("click", async () => {
              modalOutput.innerHTML = "Resetting...";
              try {
                await runShell(`sh ${MODDIR}/boot_hash.sh clear`);
                popup("Boot hash reset ✅", "success");
              } catch {
                popup("Failed to reset ❌", "error");
              } finally {
                closeModal();
              }
            });
          }, 80);
        } else if (type === "piffork") {
          const gf = document.createElement("iframe");
          gf.src = "./PlayIntegrityFork/index.html";
          gf.style.border = "none";
          gf.style.width = "100%";
          gf.style.height = "100%";
          gf.style.flex = "1";
          gf.style.borderRadius = "0";
          openModal("", "", true);
          modalOutput.innerHTML = "";
          modalOutput.appendChild(gf);
          popup(mapping.start, mapping.type);
          return;
        } else if (type === "flags") {
          const gf = document.createElement("iframe");
          gf.src = "./Flags/index.html";
          gf.style.border = "none";
          gf.style.width = "100%";
          gf.style.height = "100%";
          gf.style.flex = "1";
          gf.style.borderRadius = "0";
          openModal("", "", true);
          modalOutput.innerHTML = "";
          modalOutput.appendChild(gf);
          popup(mapping.start, mapping.type);
          return;
        } else if (script === "support") {
  const content = `<style>
.donate-modal *{font-family:inherit;box-sizing:border-box}
.donate-modal{padding-top:0;margin-top:-1rem}
.donate-header{font-size:0.9rem;font-weight:500;text-align:center;margin-bottom:1.2rem;color:var(--fg)}
.donate-entry{display:flex;flex-direction:column;align-items:center;margin-bottom:1.5rem}
.coin{width:170px!important;height:170px!important;margin:0 auto 0.6rem auto!important;display:block}
.donate-address-row{display:flex;align-items:center;justify-content:space-between;background-color:var(--panel-bg);padding:0.7rem 0.9rem;border-radius:10px;font-family:monospace;font-size:0.8rem;word-break:break-all;border:1px solid var(--border-color);margin-bottom:0.5rem}
.donate-address{flex-grow:1;margin-right:0.8rem}
.copy-btn{background:var(--accent);color:var(--bg);border:none;padding:14px 12px;border-radius:8px;cursor:pointer;font-size:0.7rem;font-weight:600}
..supporter-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 0.4rem;
  background-color: var(--panel-bg);
  padding: 1rem;
  border-radius: 12px;
  border: 1px solid var(--border-color);
  margin-bottom: 0.8rem;
  text-align: center;
}

.supporter-avatar {
  width: 100px;
  height: 100px;
  border-radius: 50%;
  object-fit: cover;
  border: 2px solid var(--accent);
  display: block;
}

.supporter-info {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.supporter-name {
  font-weight: 600;
  font-size: 0.95rem;
  margin-top: 0.3rem;
}

.supporter-donation {
  font-size: 0.85rem;
  color: var(--fg-muted);
}

.supporter-link {
  font-size: 0.8rem;
  color: var(--accent);
  text-decoration: none;
}
</style>

<div class="donate-modal">
  <div class="donate-header">Only donate if you're earning.<br>Students and unemployed supporters, your kindness is more than enough 💖</div>

  <div class="donate-entry">
  <img 
    src="https://raw.githubusercontent.com/MeowDump/Integrity-Box/main/DUMP/binance.png" 
    alt="Binance Pay ID" 
    style="width:335px; height:432px; max-width:none; display:block;"
  />
    <span>Binance Pay ID</span>
  </div>
  <div class="donate-address-row">
    <span class="donate-address">69695263</span>
    <button class="copy-btn" data-copy="69695263">🪙</button>
  </div>

  <div class="donate-entry">
    <img src="https://raw.githubusercontent.com/VadimMalykhin/binance-icons/main/crypto/busd.svg" alt="TRC20 USDT" class="coin" />
    <span>TRC20 USDT</span>
  </div>
  <div class="donate-address-row">
    <span class="donate-address">TCfhyVTfJDw8gHQT8Ph7DknNgie6ZAH5Bt</span>
    <button class="copy-btn" data-copy="TCfhyVTfJDw8gHQT8Ph7DknNgie6ZAH5Bt">🪙</button>
  </div>

  <div class="donate-entry">
    <img src="https://raw.githubusercontent.com/VadimMalykhin/binance-icons/main/crypto/busd.svg" alt="BEP20 USDT" class="coin" />
    <span>BEP20 USDT</span>
  </div>
  <div class="donate-address-row">
    <span class="donate-address">0x6b3f76339f2953db765dd2fb305784643e7d49df</span>
    <button class="copy-btn" data-copy="0x6b3f76339f2953db765dd2fb305784643e7d49df">🪙</button>
  </div>

  <div class="donate-entry">
    <img src="https://ziadoua.github.io/m3-Markdown-Badges/badges/PayPal/paypal1.svg" alt="PayPal" class="coin" />
  </div>
  <div class="donate-address-row">
    <span class="donate-address">https://paypal.me/TempMeow</span>
    <button class="copy-btn" data-copy="https://paypal.me/TempMeow">🪙</button>
  </div>

  <div style="margin-top:1.5rem;font-size:0.95rem;text-align:center;font-weight:600">🌟 Supporters 🌟</div>
  <div class="supporter-card">
    <img src="https://cdn.dribbble.com/userupload/10843376/file/original-248680dabe5bc22679fba9d666801606.png?resize=1600x1200&vertical=center" alt="Anonymous" class="supporter-avatar" />
    <div class="supporter-info">
      <div class="supporter-name">Anonymous</div>
      <div class="supporter-donation">Donated: $1,000</div>
    </div>
  </div>
  
  <div class="supporter-card">
    <img src="https://cdn.dribbble.com/userupload/10843376/file/original-248680dabe5bc22679fba9d666801606.png?resize=1600x1200&vertical=center" alt="William Jane" class="supporter-avatar" />
    <div class="supporter-info">
      <div class="supporter-name">William Jane</div>
      <div class="supporter-donation">Donated: $200</div>
    </div>
  </div>

  <div class="supporter-card">
    <img src="https://raw.githubusercontent.com/MeowDump/MeowDump/refs/heads/main/Assets/Robert.jpg" alt="Robert" class="supporter-avatar" />
    <div class="supporter-info">
      <div class="supporter-name">Robert</div>
      <div class="supporter-donation">Donated: $100</div>
    </div>
  </div>
  
  <div class="supporter-card">
    <img src="https://cdn.dribbble.com/userupload/10843376/file/original-248680dabe5bc22679fba9d666801606.png?resize=1600x1200&vertical=center" alt="Muhammad Fahad" class="supporter-avatar" />
    <div class="supporter-info">
      <div class="supporter-name">Muhammad Fahad</div>
      <div class="supporter-donation">Donated: $85</div>
    </div>
  </div>

<div class="supporter-card">
  <img src="https://cdn.dribbble.com/userupload/10843376/file/original-248680dabe5bc22679fba9d666801606.png?resize=1600x1200&vertical=center" alt="Mateo García" class="supporter-avatar" />
  <div class="supporter-info">
    <div class="supporter-name">Mateo García</div>
    <div class="supporter-donation">Donated: $75</div>
  </div>
</div>

<div class="supporter-card">
  <img src="https://cdn.dribbble.com/userupload/10843376/file/original-248680dabe5bc22679fba9d666801606.png?resize=1600x1200&vertical=center" alt="Tariq Hassan" class="supporter-avatar" />
  <div class="supporter-info">
    <div class="supporter-name">Tariq Hassan</div>
    <div class="supporter-donation">Donated: $100</div>
  </div>
</div>

<div class="supporter-card">
  <img src="https://cdn.dribbble.com/userupload/10843376/file/original-248680dabe5bc22679fba9d666801606.png?resize=1600x1200&vertical=center" alt="Liam O'Sullivan" class="supporter-avatar" />
  <div class="supporter-info">
    <div class="supporter-name">Liam O'Sullivan</div>
    <div class="supporter-donation">Donated: $60</div>
  </div>
</div>

<div class="supporter-card">
  <img src="https://cdn.dribbble.com/userupload/10843376/file/original-248680dabe5bc22679fba9d666801606.png?resize=1600x1200&vertical=center" alt="Akio Tanaka" class="supporter-avatar" />
  <div class="supporter-info">
    <div class="supporter-name">Akio Tanaka</div>
    <div class="supporter-donation">Donated: $80</div>
  </div>
</div>

<div class="supporter-card">
  <img src="https://cdn.dribbble.com/userupload/10843376/file/original-248680dabe5bc22679fba9d666801606.png?resize=1600x1200&vertical=center" alt="Andrei Petrov" class="supporter-avatar" />
  <div class="supporter-info">
    <div class="supporter-name">Andrei Petrov</div>
    <div class="supporter-donation">Donated: $130</div>
  </div>
</div>

<div class="supporter-card">
  <img src="https://cdn.dribbble.com/userupload/10843376/file/original-248680dabe5bc22679fba9d666801606.png?resize=1600x1200&vertical=center" alt="Kwame Mensah" class="supporter-avatar" />
  <div class="supporter-info">
    <div class="supporter-name">Kwame Mensah</div>
    <div class="supporter-donation">Donated: $50</div>
  </div>
</div>

<div class="supporter-card">
  <img src="https://cdn.dribbble.com/userupload/10843376/file/original-248680dabe5bc22679fba9d666801606.png?resize=1600x1200&vertical=center" alt="Niko Dimitrov" class="supporter-avatar" />
  <div class="supporter-info">
    <div class="supporter-name">Niko Dimitrov</div>
    <div class="supporter-donation">Donated: $90</div>
  </div>
</div>

<div class="supporter-card">
  <img src="https://cdn.dribbble.com/userupload/10843376/file/original-248680dabe5bc22679fba9d666801606.png?resize=1600x1200&vertical=center" alt="Mohammed Al-Farsi" class="supporter-avatar" />
  <div class="supporter-info">
    <div class="supporter-name">Mohammed Al-Farsi</div>
    <div class="supporter-donation">Donated: $70</div>
  </div>
</div>

<div class="supporter-card">
  <img src="https://cdn.dribbble.com/userupload/10843376/file/original-248680dabe5bc22679fba9d666801606.png?resize=1600x1200&vertical=center" alt="Jean Dupont" class="supporter-avatar" />
  <div class="supporter-info">
    <div class="supporter-name">Jean Dupont</div>
    <div class="supporter-donation">Donated: $60</div>
  </div>
</div>

<div class="supporter-card">
  <img src="https://cdn.dribbble.com/userupload/10843376/file/original-248680dabe5bc22679fba9d666801606.png?resize=1600x1200&vertical=center" alt="Rajiv Mehta" class="supporter-avatar" />
  <div class="supporter-info">
    <div class="supporter-name">Rajiv Mehta</div>
    <div class="supporter-donation">Donated: $110</div>
  </div>
</div>

  <div class="supporter-card">
    <img src="https://cdn.dribbble.com/userupload/10843376/file/original-248680dabe5bc22679fba9d666801606.png?resize=1600x1200&vertical=center" alt="Abhinav Singh" class="supporter-avatar" />
    <div class="supporter-info">
      <div class="supporter-name">Abhinav Singh</div>
      <div class="supporter-donation">Donated: $50</div>
    </div>
  </div>
  
  <div class="supporter-card">
    <img src="https://cdn.dribbble.com/userupload/10843376/file/original-248680dabe5bc22679fba9d666801606.png?resize=1600x1200&vertical=center" alt="Abhishek Singh" class="supporter-avatar" />
    <div class="supporter-info">
      <div class="supporter-name">Abhishek Sharma</div>
      <div class="supporter-donation">Donated: $45</div>
    </div>
  </div>

  <div class="supporter-card">
    <img src="https://raw.githubusercontent.com/MeowDump/MeowDump/refs/heads/main/Assets/tenma.jpg" alt="Dr. Tenma" class="supporter-avatar" />
    <div class="supporter-info">
      <div class="supporter-name">Dr. Tenma</div>
      <div class="supporter-donation">Donated: $10</div>
    </div>
  </div>
  
</div>`;
          openModal("Support the Developer", content, true);
          setTimeout(() => {
            document.querySelectorAll('.copy-btn').forEach(cb => {
              cb.addEventListener('click', () => {
                const text = cb.getAttribute('data-copy') || "";
                if (!navigator.clipboard) { popup("Clipboard unavailable", "error"); return; }
                navigator.clipboard.writeText(text).then(() => {
                  cb.textContent = "🩷";
                  setTimeout(() => (cb.textContent = "✅"), 1500);
                }).catch(() => popup("Failed to copy", "error"));
              });
            });
          }, 80);
        } else {
          if (!command) throw new Error("No script specified");
          try {
            const out = await runShell(command);
            popup(mapping.success, "success");
          } catch (err) {
            popup(`Error: ${err.message || String(err)}`, "error");
          }
        }
      } catch (e) {
        popup(`Error: ${e.message || String(e)}`, "error");
      } finally {
        btn.classList.remove("loading");
        setTimeout(updateDashboard, 1000);
      }
    });
  });

  modalClose?.addEventListener("click", closeModal);
  modalBackdrop?.addEventListener("click", (e) => { if (e.target === modalBackdrop) closeModal(); });
  document.addEventListener("keydown", (e) => { if (e.key === "Escape" && modalBackdrop && !modalBackdrop.classList.contains("hidden")) closeModal(); });

  const langDropdown = document.getElementById("lang-dropdown");
  const savedLang = localStorage.getItem("lang") || "en";
  if (langDropdown) {
    langDropdown.value = savedLang;
    langDropdown.addEventListener("change", async () => {
      const l = langDropdown.value || "en";
      await changeLanguage(l);
    });
    await changeLanguage(savedLang);
  }

  const toggle = document.getElementById("theme-toggle");
  const savedTheme = localStorage.getItem("theme") || "dark";
  function applyTheme(theme) {
    if (theme === "light") {
      document.documentElement.classList.add("light");
      document.documentElement.classList.remove("dark");
      if (toggle) toggle.checked = false;
    } else {
      document.documentElement.classList.remove("light");
      document.documentElement.classList.add("dark");
      if (toggle) toggle.checked = true;
    }
  }
  applyTheme(savedTheme);
  if (toggle) {
    toggle.addEventListener("change", () => {
      const newTheme = toggle.checked ? "dark" : "light";
      localStorage.setItem("theme", newTheme);
      applyTheme(newTheme);
    });
  }
});
