-- Locale.lua
local IC = ItemCrusher
IC.Locale = {}

-- Small helper: deep-ish copy for nested tables (RARITY)
local function CopyTable(src)
  local t = {}
  for k, v in pairs(src) do
    if type(v) == "table" then
      local nt = {}
      for k2, v2 in pairs(v) do nt[k2] = v2 end
      t[k] = nt
    else
      t[k] = v
    end
  end
  return t
end

-- English base (fallback). All other locales can override only what differs.
-- HELP matches your new spec (no DELETE typing hint).
local BASE_EN = {
  TITLE = "ItemCrusher",
  HELP =
    "Top: already known/learned items. Below: grouped by rarity (ascending).\n" ..
    "Click icons to mark (big green check).\n" ..
    "Delete: One item stack per click.\n" ..
    "Hearthstones are hidden.",
  CLEAR = "Clear",
  DELETE = "Delete",

  STATUS_NONE = "No items selected.",
  STATUS_READY = "Ready: %d selected. One item stack per click.",
  STATUS_POPUP = "Delete popup open – confirm, then click again.",
  STATUS_LOCKED = "Slot locked – try again.",
  STATUS_CURSOR = "Cursor occupied/no pickup – please click again.",
  STATUS_DONE = "Done.",

  OPT_TITLE = "ItemCrusher",
  OPT_SUB = "Settings",
  OPT_LANG = "Language",
  OPT_HINT = "Language is saved. Default is chosen once from client locale.",

  OPT_MINIMAP = "Minimap icon",
  OPT_MINIMAP_LOCK = "Lock icon position",

  SLASH_HELP = "/itemcrusher  (window)\n/itemcrusher options  (settings)",

  MM_TIP_TITLE = "ItemCrusher",
  MM_TIP_LEFT = "Left: Toggle window",
  MM_TIP_RIGHT = "Right: Settings",
  MM_TIP_DRAG = "Drag: Move icon",
  MM_TIP_LOCKED = "Position locked",

  KNOWN_HEADER = "Already known",

  RARITY = {
    [7] = "Heirloom",
    [6] = "Artifact",
    [5] = "Legendary",
    [4] = "Epic",
    [3] = "Rare",
    [2] = "Uncommon",
    [1] = "Common",
    [0] = "Poor",
    [-1] = "Unknown",
  },
}

-- Language names shown in the Settings dropdown
-- Reduced to the languages you want to support now.
local LANGUAGE_NAMES = {
  en = "English",
  de = "Deutsch",
  pt = "Português",
  fr = "Français",
  es = "Español",
  it = "Italiano",
  ru = "Русский",
  uk = "Українська",
  ko = "한국어",
  zhCN = "简体中文",
}

-- Locale overrides: only strings that differ from BASE_EN.
-- (HELP is updated everywhere already)
local LOCALES = {
  de = {
    HELP =
      "Oben: bereits bekannte/erlernte Items. Darunter: nach Seltenheit (aufsteigend) gruppiert.\n" ..
      "Icons anklicken = markieren (großer grüner Haken).\n" ..
      "Löschen: Pro Klick wird 1 Itemstack gelöscht.\n" ..
      "Ruhesteine werden ausgeblendet.",
    CLEAR = "Abwählen",
    DELETE = "Löschen",

    STATUS_NONE = "Keine Items markiert.",
    STATUS_READY = "Bereit: %d markiert. Pro Klick 1 Itemstack.",
    STATUS_POPUP = "Löschdialog offen – bestätige, dann erneut klicken.",
    STATUS_LOCKED = "Slot gelockt – versuch's nochmal.",
    STATUS_CURSOR = "Cursor war belegt/kein Pickup – bitte nochmal klicken.",
    STATUS_DONE = "Fertig.",

    OPT_SUB = "Einstellungen",
    OPT_LANG = "Sprache",
    OPT_HINT = "Sprache wird gespeichert. Standard wird einmalig aus der Client-Sprache abgeleitet.",

    OPT_MINIMAP = "Minimap-Icon",
    OPT_MINIMAP_LOCK = "Icon-Position sperren",

    SLASH_HELP = "/itemcrusher  (Fenster)\n/itemcrusher options  (Einstellungen)",

    MM_TIP_LEFT = "Links: Fenster öffnen/schließen",
    MM_TIP_RIGHT = "Rechts: Einstellungen",
    MM_TIP_DRAG = "Ziehen: Icon bewegen",
    MM_TIP_LOCKED = "Position gesperrt",

    KNOWN_HEADER = "Bereits bekannt",

    RARITY = {
      [7] = "Erbstück",
      [6] = "Artefakt",
      [5] = "Legendär",
      [4] = "Episch",
      [3] = "Selten",
      [2] = "Ungewöhnlich",
      [1] = "Gewöhnlich",
      [0] = "Schlecht",
      [-1] = "Unbekannt",
    },
  },

  fr = {
    HELP =
      "En haut : objets déjà connus/appris. En dessous : groupés par rareté (croissante).\n" ..
      "Cliquez sur les icônes pour marquer (grande coche verte).\n" ..
      "Supprimer : une pile d’objets par clic.\n" ..
      "Les pierres de foyer sont masquées.",
    CLEAR = "Effacer",
    DELETE = "Supprimer",

    STATUS_NONE = "Aucun objet sélectionné.",
    STATUS_READY = "Prêt : %d sélectionné(s). Une pile par clic.",
    STATUS_POPUP = "Confirmation de suppression ouverte – validez, puis recliquez.",
    STATUS_LOCKED = "Emplacement verrouillé – réessayez.",
    STATUS_CURSOR = "Curseur occupé / impossible de prendre – veuillez recliquer.",
    STATUS_DONE = "Terminé.",

    OPT_SUB = "Options",
    OPT_LANG = "Langue",
    OPT_MINIMAP = "Icône de la mini-carte",
    OPT_MINIMAP_LOCK = "Verrouiller la position de l’icône",

    SLASH_HELP = "/itemcrusher  (fenêtre)\n/itemcrusher options  (options)",

    MM_TIP_LEFT = "Clic gauche : ouvrir/fermer",
    MM_TIP_RIGHT = "Clic droit : options",
    MM_TIP_DRAG = "Glisser : déplacer l’icône",
    MM_TIP_LOCKED = "Position verrouillée",

    KNOWN_HEADER = "Déjà connu",

    RARITY = {
      [7] = "Héritage",
      [6] = "Artefact",
      [5] = "Légendaire",
      [4] = "Épique",
      [3] = "Rare",
      [2] = "Inhabituel",
      [1] = "Commun",
      [0] = "Médiocre",
      [-1] = "Inconnu",
    },
  },

  es = {
    HELP =
      "Arriba: objetos ya conocidos/aprendidos. Abajo: agrupados por rareza (ascendente).\n" ..
      "Haz clic en los iconos para marcar (gran marca verde).\n" ..
      "Borrar: una pila de objetos por clic.\n" ..
      "Las piedras de hogar se ocultan.",
    CLEAR = "Limpiar",
    DELETE = "Borrar",

    STATUS_NONE = "No hay objetos seleccionados.",
    STATUS_READY = "Listo: %d seleccionado(s). Una pila por clic.",
    STATUS_POPUP = "Diálogo de borrado abierto: confirma y vuelve a hacer clic.",
    STATUS_LOCKED = "Casilla bloqueada: inténtalo de nuevo.",
    STATUS_CURSOR = "Cursor ocupado / no se pudo coger: vuelve a hacer clic.",
    STATUS_DONE = "Hecho.",

    OPT_SUB = "Ajustes",
    OPT_LANG = "Idioma",
    OPT_MINIMAP = "Icono del minimapa",
    OPT_MINIMAP_LOCK = "Bloquear posición del icono",

    SLASH_HELP = "/itemcrusher  (ventana)\n/itemcrusher options  (ajustes)",

    MM_TIP_LEFT = "Izq: abrir/cerrar",
    MM_TIP_RIGHT = "Der: ajustes",
    MM_TIP_DRAG = "Arrastrar: mover icono",
    MM_TIP_LOCKED = "Posición bloqueada",

    KNOWN_HEADER = "Ya conocido",

    RARITY = {
      [7] = "Reliquia",
      [6] = "Artefacto",
      [5] = "Legendario",
      [4] = "Épico",
      [3] = "Raro",
      [2] = "Poco común",
      [1] = "Común",
      [0] = "Pobre",
      [-1] = "Desconocido",
    },
  },

  pt = {
    HELP =
      "Topo: itens já conhecidos/aprendidos. Abaixo: agrupados por raridade (crescente).\n" ..
      "Clique nos ícones para marcar (grande visto verde).\n" ..
      "Excluir: uma pilha de itens por clique.\n" ..
      "Pedras de Regresso são ocultadas.",
    CLEAR = "Limpar",
    DELETE = "Excluir",

    STATUS_NONE = "Nenhum item selecionado.",
    STATUS_READY = "Pronto: %d selecionado(s). Uma pilha por clique.",
    STATUS_POPUP = "Popup de exclusão aberto – confirme e clique novamente.",
    STATUS_LOCKED = "Slot bloqueado – tente novamente.",
    STATUS_CURSOR = "Cursor ocupado / não foi possível pegar – clique novamente.",
    STATUS_DONE = "Concluído.",

    OPT_SUB = "Configurações",
    OPT_LANG = "Idioma",
    OPT_MINIMAP = "Ícone do minimapa",
    OPT_MINIMAP_LOCK = "Travar posição do ícone",

    SLASH_HELP = "/itemcrusher  (janela)\n/itemcrusher options  (configurações)",

    MM_TIP_LEFT = "Esq: abrir/fechar",
    MM_TIP_RIGHT = "Dir: configurações",
    MM_TIP_DRAG = "Arrastar: mover ícone",
    MM_TIP_LOCKED = "Posição travada",

    KNOWN_HEADER = "Já conhecido",

    RARITY = {
      [7] = "Herança",
      [6] = "Artefato",
      [5] = "Lendário",
      [4] = "Épico",
      [3] = "Raro",
      [2] = "Incomum",
      [1] = "Comum",
      [0] = "Pobre",
      [-1] = "Desconhecido",
    },
  },

  it = {
    HELP =
      "In alto: oggetti già conosciuti/imparati. Sotto: raggruppati per rarità (crescente).\n" ..
      "Clicca sulle icone per selezionare (grande spunta verde).\n" ..
      "Elimina: una pila di oggetti per clic.\n" ..
      "Le Pietre del Ritorno sono nascoste.",
    CLEAR = "Azzera",
    DELETE = "Elimina",

    STATUS_NONE = "Nessun oggetto selezionato.",
    STATUS_READY = "Pronto: %d selezionato(i). Una pila per clic.",
    STATUS_POPUP = "Popup di eliminazione aperto – conferma e clicca di nuovo.",
    STATUS_LOCKED = "Slot bloccato – riprova.",
    STATUS_CURSOR = "Cursore occupato / impossibile prelevare – clicca di nuovo.",
    STATUS_DONE = "Fatto.",

    OPT_SUB = "Impostazioni",
    OPT_LANG = "Lingua",
    OPT_MINIMAP = "Icona minimappa",
    OPT_MINIMAP_LOCK = "Blocca posizione icona",

    SLASH_HELP = "/itemcrusher  (finestra)\n/itemcrusher options  (impostazioni)",

    MM_TIP_LEFT = "Sinistra: apri/chiudi",
    MM_TIP_RIGHT = "Destra: impostazioni",
    MM_TIP_DRAG = "Trascina: sposta icona",
    MM_TIP_LOCKED = "Posizione bloccata",

    KNOWN_HEADER = "Già conosciuto",

    RARITY = {
      [7] = "Cimelio",
      [6] = "Artefatto",
      [5] = "Leggendario",
      [4] = "Epico",
      [3] = "Raro",
      [2] = "Non comune",
      [1] = "Comune",
      [0] = "Scarso",
      [-1] = "Sconosciuto",
    },
  },

  ru = {
    HELP =
      "Сверху: уже известные/изученные предметы. Ниже: сгруппировано по редкости (по возрастанию).\n" ..
      "Нажмите на иконки, чтобы отметить (большая зелёная галочка).\n" ..
      "Удалить: один стак предметов за клик.\n" ..
      "Камни возвращения скрыты.",
    CLEAR = "Очистить",
    DELETE = "Удалить",

    STATUS_NONE = "Нет выбранных предметов.",
    STATUS_READY = "Готово: %d выбрано. Один стак за клик.",
    STATUS_POPUP = "Окно подтверждения удаления открыто — подтвердите и нажмите снова.",
    STATUS_LOCKED = "Слот заблокирован — попробуйте ещё раз.",
    STATUS_CURSOR = "Курсор занят / не удалось взять — нажмите ещё раз.",
    STATUS_DONE = "Готово.",

    OPT_SUB = "Настройки",
    OPT_LANG = "Язык",
    OPT_MINIMAP = "Значок на миникарте",
    OPT_MINIMAP_LOCK = "Закрепить позицию значка",

    SLASH_HELP = "/itemcrusher  (окно)\n/itemcrusher options  (настройки)",

    MM_TIP_LEFT = "ЛКМ: открыть/закрыть",
    MM_TIP_RIGHT = "ПКМ: настройки",
    MM_TIP_DRAG = "Перетащить: переместить значок",
    MM_TIP_LOCKED = "Позиция закреплена",

    KNOWN_HEADER = "Уже известно",

    RARITY = {
      [7] = "Реликвия",
      [6] = "Артефакт",
      [5] = "Легендарный",
      [4] = "Эпический",
      [3] = "Редкий",
      [2] = "Необычный",
      [1] = "Обычный",
      [0] = "Плохой",
      [-1] = "Неизвестно",
    },
  },

  uk = {
    HELP =
      "Вгорі: вже відомі/вивчені предмети. Нижче: згруповано за рідкістю (за зростанням).\n" ..
      "Клацніть по іконках, щоб позначити (велика зелена галочка).\n" ..
      "Видалити: один стак предметів за клік.\n" ..
      "Камені повернення приховано.",
    CLEAR = "Очистити",
    DELETE = "Видалити",

    STATUS_NONE = "Немає вибраних предметів.",
    STATUS_READY = "Готово: %d вибрано. Один стак за клік.",
    STATUS_POPUP = "Вікно підтвердження видалення відкрите — підтвердьте і клацніть знову.",
    STATUS_LOCKED = "Слот заблоковано — спробуйте ще раз.",
    STATUS_CURSOR = "Курсор зайнятий / не вдалося взяти — клацніть ще раз.",
    STATUS_DONE = "Готово.",

    OPT_SUB = "Налаштування",
    OPT_LANG = "Мова",
    OPT_MINIMAP = "Іконка мінікарти",
    OPT_MINIMAP_LOCK = "Закріпити позицію іконки",

    SLASH_HELP = "/itemcrusher  (вікно)\n/itemcrusher options  (налаштування)",

    MM_TIP_LEFT = "ЛКМ: відкрити/закрити",
    MM_TIP_RIGHT = "ПКМ: налаштування",
    MM_TIP_DRAG = "Перетягнути: перемістити іконку",
    MM_TIP_LOCKED = "Позицію закріплено",

    KNOWN_HEADER = "Вже відомо",

    RARITY = {
      [7] = "Реліквія",
      [6] = "Артефакт",
      [5] = "Легендарний",
      [4] = "Епічний",
      [3] = "Рідкісний",
      [2] = "Незвичайний",
      [1] = "Звичайний",
      [0] = "Поганий",
      [-1] = "Невідомо",
    },
  },

  ko = {
    HELP =
      "위: 이미 알고/배운 아이템. 아래: 희귀도(오름차순)로 그룹화.\n" ..
      "아이콘을 클릭해 선택(큰 초록 체크).\n" ..
      "삭제: 클릭 1번당 아이템 한 묶음(스택).\n" ..
      "귀환석은 숨김 처리됩니다.",
    CLEAR = "지우기",
    DELETE = "삭제",

    STATUS_NONE = "선택된 아이템이 없습니다.",
    STATUS_READY = "준비됨: %d개 선택됨. 클릭 1번당 1스택.",
    STATUS_POPUP = "삭제 확인 창이 열려 있습니다 — 확인 후 다시 클릭하세요.",
    STATUS_LOCKED = "슬롯이 잠겨 있습니다 — 다시 시도하세요.",
    STATUS_CURSOR = "커서가 사용 중 / 집을 수 없음 — 다시 클릭하세요.",
    STATUS_DONE = "완료.",

    OPT_SUB = "설정",
    OPT_LANG = "언어",
    OPT_MINIMAP = "미니맵 아이콘",
    OPT_MINIMAP_LOCK = "아이콘 위치 잠금",

    SLASH_HELP = "/itemcrusher  (창)\n/itemcrusher options  (설정)",

    MM_TIP_LEFT = "왼쪽 클릭: 창 토글",
    MM_TIP_RIGHT = "오른쪽 클릭: 설정",
    MM_TIP_DRAG = "드래그: 아이콘 이동",
    MM_TIP_LOCKED = "위치가 잠김",

    KNOWN_HEADER = "이미 알고 있음",

    RARITY = {
      [7] = "유물급(상속품)",
      [6] = "유물",
      [5] = "전설",
      [4] = "영웅",
      [3] = "희귀",
      [2] = "고급",
      [1] = "일반",
      [0] = "하급",
      [-1] = "알 수 없음",
    },
  },

  zhCN = {
    HELP =
      "上方：已知/已学会的物品。下方：按品质（升序）分组。\n" ..
      "点击图标进行选择（大号绿色对勾）。\n" ..
      "删除：每次点击删除一组（堆叠）。\n" ..
      "炉石已隐藏。",
    CLEAR = "清除",
    DELETE = "删除",

    STATUS_NONE = "未选择任何物品。",
    STATUS_READY = "就绪：已选择 %d 个。每次点击删除一组。",
    STATUS_POPUP = "删除确认窗口已打开——确认后再次点击。",
    STATUS_LOCKED = "格子被锁定——请重试。",
    STATUS_CURSOR = "鼠标光标占用/无法拾取——请再点一次。",
    STATUS_DONE = "完成。",

    OPT_SUB = "设置",
    OPT_LANG = "语言",
    OPT_MINIMAP = "小地图图标",
    OPT_MINIMAP_LOCK = "锁定图标位置",

    SLASH_HELP = "/itemcrusher  (窗口)\n/itemcrusher options  (设置)",

    MM_TIP_LEFT = "左键：打开/关闭窗口",
    MM_TIP_RIGHT = "右键：设置",
    MM_TIP_DRAG = "拖动：移动图标",
    MM_TIP_LOCKED = "位置已锁定",

    KNOWN_HEADER = "已知",

    RARITY = {
      [7] = "传家宝",
      [6] = "神器",
      [5] = "传说",
      [4] = "史诗",
      [3] = "精良",
      [2] = "优秀",
      [1] = "普通",
      [0] = "粗糙",
      [-1] = "未知",
    },
  },
}

-- Build final locale table with fallback to English base.
function IC.Locale:Build(lang)
  local chosen = LOCALES[lang] or {}
  local out = CopyTable(BASE_EN)

  for k, v in pairs(chosen) do
    if type(v) == "table" and type(out[k]) == "table" then
      for k2, v2 in pairs(v) do
        out[k][k2] = v2
      end
    else
      out[k] = v
    end
  end

  -- Expose language names in locale table for UI use
  out.LANG_NAMES = LANGUAGE_NAMES

  IC.L = out
end

function IC.Locale:Apply()
  self:Build(IC.db.lang or "en")
  if IC.UI and IC.UI.ApplyLocale and IC.UI.title then
    IC.UI:ApplyLocale()
  end
end