const fs = require('fs');
const path = require('path');
const dataPath = path.join('assets', 'data', 'distros.json');
const backupPath = dataPath + '.bak5.' + Date.now();
const raw = fs.readFileSync(dataPath, 'utf8');
fs.writeFileSync(backupPath, raw, 'utf8');
const distros = JSON.parse(raw);
const familyMap = {
  debian: 'Debian',
  redhat: 'Red Hat',
  arch: 'Arch',
  suse: 'SUSE',
  gentoo: 'Gentoo',
  slackware: 'Slackware',
  android: 'Android',
  independent: 'Independent',
};

const keywordSets = [
  { pattern: /security|kali|parrot|backtrack|blackarch|pentoo|auditor|bugtraq|gnacktrack|cain|nethserver|pfsense|security/i, category: 'security' },
  { pattern: /studio|music|audio|creative|media|artist|video|production|design/i, category: 'creative' },
  { pattern: /lite|mini|micro|tiny|slim|light|flux|puppy|slax|lubuntu|lxde|lxqt|anti.?x|bunsen|salix|sli|xubuntu|lubuntu|linux lite|lxle|peach|sugar/i, category: 'lightweight' },
  { pattern: /server|nas|cloud|container|openmediavault|freenas|mail|file|router|gateway|appliance|storage|linux router|web|kloxo|zentyal/i, category: 'server' },
  { pattern: /education|edubuntu|doudou|school|classroom|learning|kdeedu|sugar/i, category: 'education' },
  { pattern: /mobile|android|lineage|cyanogenmod|grapheneos|postmarket|omnirom|android-x86|meego|sailfish|tizen|phoenix|moblin/i, category: 'mobile' },
  { pattern: /rescue|live|recover|rescatux|systemrescue|clonezilla|backbox|debug|repair|recovery|rescue/i, category: 'rescue' },
  { pattern: /gaming|game|esports|steam|play|gamer/i, category: 'gaming' },
  { pattern: /office|business|enterprise|corporate|pro|enterprise|workstation/i, category: 'business' },
];

const categoryInfo = {
  security: {
    focus: 'advanced security and penetration testing',
    useCases: ['Security', 'Penetration Testing', 'Forensics'],
    targetAudience: ['Security Professionals', 'Advanced'],
    pros: ['Preloaded security tools', 'Hardened by default', 'Designed for auditors'],
    cons: ['Not ideal as a daily desktop', 'Manufacturer support is limited'],
    defaultDesktop: 'Xfce',
    isoSize: 4.5,
    packageManager: 'APT (dpkg)',
    releaseModel: 'Rolling',
  },
  creative: {
    focus: 'creative workflows for audio, video, and design',
    useCases: ['Creative', 'Media Production', 'Desktop'],
    targetAudience: ['Artists', 'Creators', 'Multimedia Users'],
    pros: ['Rich multimedia tools', 'Optimized creative apps', 'Good for content creators'],
    cons: ['Heavier system requirements', 'Not ideal for older hardware'],
    defaultDesktop: 'GNOME',
    isoSize: 4.0,
    packageManager: 'APT (dpkg)',
    releaseModel: 'Fixed',
  },
  lightweight: {
    focus: 'lightweight performance on low-end hardware',
    useCases: ['Old Hardware', 'Desktop', 'Education'],
    targetAudience: ['Beginners', 'Older Hardware Users'],
    pros: ['Fast on older machines', 'Low memory usage', 'Clean and minimal'],
    cons: ['Simpler app selection', 'Not ideal for heavy multimedia'],
    defaultDesktop: 'Xfce',
    isoSize: 1.2,
    packageManager: 'APT (dpkg)',
    releaseModel: 'Fixed',
  },
  server: {
    focus: 'server and networking deployments',
    useCases: ['Server', 'Hosting', 'Cloud', 'Networking'],
    targetAudience: ['Administrators', 'Server Operators'],
    pros: ['Stable server packages', 'Good networking tools', 'Long-term support'],
    cons: ['Less desktop polish', 'Requires administration knowledge'],
    defaultDesktop: 'None',
    isoSize: 2.0,
    packageManager: 'APT (dpkg)',
    releaseModel: 'Fixed',
  },
  education: {
    focus: 'education and classroom learning',
    useCases: ['Education', 'Desktop', 'Kids'],
    targetAudience: ['Students', 'Teachers'],
    pros: ['Kid-friendly apps', 'Easy learning tools', 'Good for schools'],
    cons: ['Niche app collection', 'Less advanced power-user features'],
    defaultDesktop: 'GNOME',
    isoSize: 2.2,
    packageManager: 'APT (dpkg)',
    releaseModel: 'Fixed',
  },
  mobile: {
    focus: 'mobile and touch-first devices',
    useCases: ['Mobile', 'Touch', 'IoT'],
    targetAudience: ['Mobile Users', 'Android Enthusiasts'],
    pros: ['Designed for phones and tablets', 'Strong hardware support', 'Touch-friendly'],
    cons: ['Limited desktop software', 'Smaller app ecosystem'],
    defaultDesktop: 'Android UI',
    isoSize: 1.8,
    packageManager: 'APK',
    releaseModel: 'Rolling',
  },
  rescue: {
    focus: 'system rescue and recovery',
    useCases: ['Rescue', 'Live', 'Repair'],
    targetAudience: ['Administrators', 'Technicians'],
    pros: ['Bootable recovery tools', 'Repair utilities', 'Lightweight live environment'],
    cons: ['Not meant for daily desktop use', 'Limited long-term storage'],
    defaultDesktop: 'Xfce',
    isoSize: 1.5,
    packageManager: 'Various',
    releaseModel: 'Fixed',
  },
  gaming: {
    focus: 'gaming and entertainment',
    useCases: ['Gaming', 'Desktop', 'Media'],
    targetAudience: ['Gamers', 'Casual Users'],
    pros: ['Optimized for games', 'Good driver support', 'Fast performance'],
    cons: ['Less enterprise focus', 'Fewer server tools'],
    defaultDesktop: 'GNOME',
    isoSize: 3.5,
    packageManager: 'APT (dpkg)',
    releaseModel: 'Rolling',
  },
  business: {
    focus: 'business and productivity',
    useCases: ['Business', 'Office', 'Desktop'],
    targetAudience: ['Professionals', 'Enterprises'],
    pros: ['Office-ready', 'Stable updates', 'Professional tools'],
    cons: ['Not gaming-focused', 'May feel bloated for home users'],
    defaultDesktop: 'KDE Plasma',
    isoSize: 3.0,
    packageManager: 'APT (dpkg)',
    releaseModel: 'Fixed',
  },
  desktop: {
    focus: 'general desktop computing',
    useCases: ['Desktop'],
    targetAudience: ['Desktop'],
    pros: ['Well-balanced desktop experience', 'Good compatibility with common applications'],
    cons: ['Not specialized for one niche', 'May feel generic for advanced users'],
    defaultDesktop: 'GNOME',
    isoSize: 2.6,
    packageManager: 'Various',
    releaseModel: 'Fixed',
  },
};

const familyDefaults = {
  debian: {
    base: 'Debian',
    packageManager: 'APT (dpkg)',
    releaseModel: 'Fixed',
    defaultDesktop: 'GNOME',
    availableDesktops: ['GNOME', 'KDE Plasma', 'Xfce', 'MATE', 'Cinnamon'],
    initSystem: 'systemd',
    color: '#A80030',
  },
  redhat: {
    base: 'RHEL',
    packageManager: 'DNF (RPM)',
    releaseModel: 'Fixed',
    defaultDesktop: 'GNOME',
    availableDesktops: ['GNOME', 'KDE Plasma', 'Xfce'],
    initSystem: 'systemd',
    color: '#EE0000',
  },
  arch: {
    base: 'Arch Linux',
    packageManager: 'Pacman',
    releaseModel: 'Rolling',
    defaultDesktop: 'GNOME',
    availableDesktops: ['GNOME', 'KDE Plasma', 'Xfce', 'i3', 'Sway'],
    initSystem: 'systemd',
    color: '#1793D1',
  },
  suse: {
    base: 'openSUSE',
    packageManager: 'Zypper (RPM)',
    releaseModel: 'Rolling',
    defaultDesktop: 'KDE Plasma',
    availableDesktops: ['KDE Plasma', 'GNOME'],
    initSystem: 'systemd',
    color: '#73BA25',
  },
  gentoo: {
    base: 'Gentoo',
    packageManager: 'Portage',
    releaseModel: 'Rolling',
    defaultDesktop: 'KDE Plasma',
    availableDesktops: ['KDE Plasma', 'GNOME', 'Xfce'],
    initSystem: 'OpenRC',
    color: '#54487A',
  },
  slackware: {
    base: 'Slackware',
    packageManager: 'pkgtool',
    releaseModel: 'Fixed',
    defaultDesktop: 'Xfce',
    availableDesktops: ['Xfce', 'KDE Plasma'],
    initSystem: 'SysVinit',
    color: '#4458A0',
  },
  android: {
    base: 'Android',
    packageManager: 'APK',
    releaseModel: 'Rolling',
    defaultDesktop: 'Android UI',
    availableDesktops: ['Android'],
    initSystem: 'Android init',
    color: '#3DDC84',
  },
  independent: {
    base: 'Independent',
    packageManager: 'Various',
    releaseModel: 'Fixed',
    defaultDesktop: 'Unknown',
    availableDesktops: ['Desktop'],
    initSystem: 'systemd',
    color: '#607D8B',
  },
};

function normalize(value) {
  return (value || '').toString().trim();
}

function choose(value, fallback) {
  return value && value !== 'Unknown' ? value : fallback;
}

function randomFrom(list) {
  return list[Math.floor(Math.random() * list.length)];
}

function getCategory(name) {
  const lower = name.toLowerCase();
  const found = keywordSets.find((rule) => rule.pattern.test(lower));
  return found ? found.category : 'desktop';
}

function getFocus(category) {
  const item = categoryInfo[category] || categoryInfo.desktop;
  if (!item) return 'general desktop computing';
  return item.focus;
}

function buildDescription(name, family, category) {
  const familyName = familyMap[family] || familyMap.independent;
  const focus = getFocus(category);
  return `${name} is a ${familyName}-family distribution imported from the Linux distribution timeline with a focus on ${focus}.`;
}

function buildLongDescription(name, base, familyName, category, packageManager) {
  const info = categoryInfo[category] || {};
  const feature = info.focus || 'desktop computing';
  return `${name} is built on a ${base} foundation and targets ${feature}. It includes ${packageManager} package support and is shaped by the ${familyName} family heritage.`;
}

function buildPros(name, category) {
  const info = categoryInfo[category] || categoryInfo.desktop;
  const pros = [...(info.pros || ['Well-rounded feature set'])];
  const focus = info.focus || 'general desktop computing';
  if (category !== 'desktop') pros.unshift(`${name} is optimized for ${focus}`);
  else pros.unshift(`${name} offers a balanced ${focus} experience`);
  return pros.slice(0, 4);
}

function buildCons(name, category) {
  const info = categoryInfo[category] || { cons: ['Less suited for niche workflows'] };
  const cons = [...info.cons];
  if (category === 'lightweight') cons.push('Limited default applications');
  if (category === 'server') cons.push('Not focused on desktop customization');
  return cons.slice(0, 4);
}

function getSize(category, name) {
  const lower = name.toLowerCase();
  if (/lite|mini|micro|tiny|slim|light|minimal|minimalist|puppy|slax|lxle|anti.?x|bunsen|flux|sli/i.test(lower)) return 1.0;
  if (/studio|media|creative|design|audio|video|production/i.test(lower)) return 3.8;
  if (/security|kali|parrot|red|audit|security/i.test(lower)) return 4.2;
  if (/server|nas|cloud|router|gateway|openmediavault|pfsense|zentyal/i.test(lower)) return 2.5;
  if (/mobile|android|lineage|grapheneos|meego|sailfish|phoenix/i.test(lower)) return 2.0;
  if (/rescue|live|repair|clone|systemrescue/i.test(lower)) return 1.4;
  return category === 'lightweight' ? 1.0 : category === 'security' ? 4.2 : 2.6;
}

const importedPattern = /Linux distribution timeline/;
let changed = 0;
for (const entry of distros) {
  if (!entry.description || !importedPattern.test(entry.description)) continue;
  const name = normalize(entry.name);
  const family = normalize(entry.family).toLowerCase() || 'independent';
  const base = choose(normalize(entry.base), familyDefaults[family]?.base || 'Independent');
  const packageManager = choose(normalize(entry.package_manager), familyDefaults[family]?.packageManager || 'Various');
  const releaseModel = choose(normalize(entry.release_model), familyDefaults[family]?.releaseModel || 'Fixed');
  const familyName = familyMap[family] || familyMap.independent;
  const category = getCategory(name);
  const info = categoryInfo[category] || {};

  const defaultDesktop = normalize(entry.default_desktop) === 'Unknown' || !normalize(entry.default_desktop)
    ? (info.defaultDesktop || familyDefaults[family].defaultDesktop)
    : entry.default_desktop;
  const availableDesktops = Array.isArray(entry.available_desktops) && entry.available_desktops.length
    ? entry.available_desktops
    : familyDefaults[family].availableDesktops;
  const useCases = Array.isArray(entry.use_cases) && entry.use_cases.length
    ? entry.use_cases
    : (info.useCases || familyDefaults[family].useCases || ['Desktop']);
  const targetAudience = Array.isArray(entry.target_audience) && entry.target_audience.length
    ? entry.target_audience
    : (info.targetAudience || ['Desktop']);
  const color = normalize(entry.color) === '#999999' || !normalize(entry.color)
    ? familyDefaults[family]?.color || '#607D8B'
    : entry.color;

  entry.description = buildDescription(name, family, category);
  entry.long_description = buildLongDescription(name, base, familyName, category, packageManager);
  entry.website = normalize(entry.website) || '';
  entry.download = normalize(entry.download) || '';
  entry.iso_size = getSize(category, name);
  entry.base = base;
  entry.family = family;
  entry.package_manager = packageManager;
  entry.default_desktop = defaultDesktop;
  entry.available_desktops = availableDesktops;
  entry.release_model = releaseModel;
  entry.target_audience = targetAudience;
  entry.use_cases = useCases;
  entry.init_system = normalize(entry.init_system) === 'Unknown' || !normalize(entry.init_system)
    ? familyDefaults[family]?.initSystem || 'systemd'
    : entry.init_system;
  entry.pros = buildPros(name, category);
  entry.cons = buildCons(name, category);
  entry.popularity_rank = entry.popularity_rank || 50;
  entry.color = color;
  entry.first_release = normalize(entry.first_release) || 'Unknown';
  entry.latest_version = normalize(entry.latest_version) || 'Unknown';

  changed++;
}
fs.writeFileSync(dataPath, JSON.stringify(distros, null, 2), 'utf8');
console.log(`Updated ${changed} imported distro entries with unique metadata.`);
