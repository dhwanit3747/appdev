const fs = require('fs');
const path = require('path');
const dataPath = path.join('assets', 'data', 'distros.json');
if (!fs.existsSync(dataPath)) {
  console.error('distros.json not found at', dataPath);
  process.exit(1);
}
const raw = fs.readFileSync(dataPath, 'utf8');
const distros = JSON.parse(raw);
const familyRules = [
  {
    family: 'android',
    pattern: /android|lineageos|cyanogenmod|grapheneos|aosp|postmarketos|phosh/i,
    base: 'Android',
    packageManager: 'APK',
    releaseModel: 'Rolling',
    defaultDesktop: 'Android UI',
    availableDesktops: ['Android'],
    useCases: ['Mobile', 'IoT'],
    targetAudience: ['Mobile Users'],
    color: '#3DDC84',
  },
  {
    family: 'arch',
    pattern: /arch|artix|antergos|manjaro|blackarch|archbang|ctkarch|archlabs|archmerge|arco|cinnarch|arcol|kde neon|arch linux 32|arch linux arm|archlinux/i,
    base: 'Arch Linux',
    packageManager: 'Pacman',
    releaseModel: 'Rolling',
    defaultDesktop: 'GNOME',
    availableDesktops: ['GNOME', 'KDE Plasma', 'Xfce', 'i3', 'Sway'],
    useCases: ['Desktop', 'Development'],
    targetAudience: ['Intermediate', 'Advanced'],
    color: '#1793D1',
  },
  {
    family: 'gentoo',
    pattern: /gentoo|sabayon|calculate|funtoo|source.*based/i,
    base: 'Gentoo',
    packageManager: 'Portage',
    releaseModel: 'Rolling',
    defaultDesktop: 'KDE Plasma',
    availableDesktops: ['KDE Plasma', 'GNOME', 'Xfce'],
    useCases: ['Desktop', 'Development'],
    targetAudience: ['Advanced'],
    color: '#54487A',
  },
  {
    family: 'slackware',
    pattern: /slackware|slax|salix|simplymepis|mepis|vector|dsl|debian?slack/i,
    base: 'Slackware',
    packageManager: 'pkgtool',
    releaseModel: 'Fixed',
    defaultDesktop: 'Xfce',
    availableDesktops: ['Xfce', 'KDE Plasma'],
    useCases: ['Desktop', 'Servers'],
    targetAudience: ['Intermediate', 'Advanced'],
    color: '#4458A0',
  },
  {
    family: 'suse',
    pattern: /suse|opensuse|geckolinux|leap|tumbleweed|evolution|sles|suse linux/i,
    base: 'openSUSE',
    packageManager: 'Zypper (RPM)',
    releaseModel: 'Rolling',
    defaultDesktop: 'KDE Plasma',
    availableDesktops: ['KDE Plasma', 'GNOME'],
    useCases: ['Desktop', 'Server'],
    targetAudience: ['Intermediate'],
    color: '#73BA25',
  },
  {
    family: 'redhat',
    pattern: /fedora|centos|rocky|red hat|rhel|oracle|mandriva|mandrake|mageia|pclinuxos|clearos|rosalinux|scientific|el|oracle enterprise/i,
    base: 'RHEL',
    packageManager: 'DNF (RPM)',
    releaseModel: 'Fixed',
    defaultDesktop: 'GNOME',
    availableDesktops: ['GNOME', 'KDE Plasma', 'Xfce'],
    useCases: ['Desktop', 'Server'],
    targetAudience: ['Intermediate', 'Server'],
    color: '#EE0000',
  },
  {
    family: 'debian',
    pattern: /debian|ubuntu|mint|kali|parrot|raspbian|raspberry|anti.?x|bodhi|deepin|elementary|zorin|pop|mx linux|linux mint|linux lite|linux console|ubiquity|linux from scratch|distro.*linux/i,
    base: 'Debian',
    packageManager: 'APT (dpkg)',
    releaseModel: 'Fixed',
    defaultDesktop: 'GNOME',
    availableDesktops: ['GNOME', 'KDE Plasma', 'Xfce', 'MATE', 'Cinnamon'],
    useCases: ['Desktop', 'Education'],
    targetAudience: ['Beginners', 'Desktop'],
    color: '#A80030',
  },
];

const familyDisplay = {
  android: 'Android',
  arch: 'Arch',
  gentoo: 'Gentoo',
  slackware: 'Slackware',
  suse: 'SUSE',
  redhat: 'Red Hat',
  debian: 'Debian',
  independent: 'Independent',
};

const fallback = {
  family: 'independent',
  base: 'Independent',
  packageManager: 'Unknown',
  releaseModel: 'Unknown',
  defaultDesktop: 'Unknown',
  availableDesktops: ['Unknown'],
  useCases: ['Desktop'],
  targetAudience: ['Desktop'],
  color: '#607D8B',
};

function toHex(color) {
  const rgb = color.replace('#', '');
  if (rgb.length === 6) return `#${rgb}`;
  return '#607D8B';
}

let changed = 0;
for (const entry of distros) {
  const desc = entry.description || '';
  if (typeof desc === 'string' && desc.includes('Linux distribution timeline')) {
    const name = entry.name || 'Unknown';
    let rule = familyRules.find((r) => r.pattern.test(name));
    if (!rule) {
      // heuristic by name keyword if not explicitly matched
      if (/linux/i.test(name) && !/android|chrome|ios|osx/i.test(name)) {
        rule = familyRules.find((r) => r.family === 'debian');
      }
      if (!rule) {
        rule = fallback;
      }
    }

    const family = rule.family || fallback.family;
    const familyName = familyDisplay[family] || family;
    const base = rule.base || fallback.base;
    const packageManager = rule.packageManager || fallback.packageManager;
    const releaseModel = rule.releaseModel || fallback.releaseModel;
    const defaultDesktop = rule.defaultDesktop || fallback.defaultDesktop;
    const availableDesktops = Array.isArray(entry.available_desktops) && entry.available_desktops.length
      ? entry.available_desktops
      : rule.availableDesktops || fallback.availableDesktops;
    const useCases = Array.isArray(entry.use_cases) && entry.use_cases.length
      ? entry.use_cases
      : rule.useCases || fallback.useCases;
    const targetAudience = Array.isArray(entry.target_audience) && entry.target_audience.length
      ? entry.target_audience
      : rule.targetAudience || fallback.targetAudience;
    const color = entry.color && entry.color !== '#999999' ? entry.color : toHex(rule.color || fallback.color);

    entry.family = family;
    if (!entry.base || entry.base === 'Independent') entry.base = base;
    if (!entry.package_manager || entry.package_manager === 'Unknown') entry.package_manager = packageManager;
    if (!entry.release_model || entry.release_model === 'Unknown') entry.release_model = releaseModel;
    if (!entry.default_desktop || entry.default_desktop === 'Unknown') entry.default_desktop = defaultDesktop;
    entry.available_desktops = availableDesktops;
    entry.use_cases = useCases;
    entry.target_audience = targetAudience;
    if (family === 'independent') {
      if (!entry.package_manager || entry.package_manager === 'Unknown') entry.package_manager = 'Varies';
      if (!entry.release_model || entry.release_model === 'Unknown') entry.release_model = 'Fixed';
      if (!entry.default_desktop || entry.default_desktop === 'Unknown') entry.default_desktop = 'Unknown';
      if (!Array.isArray(entry.available_desktops) || !entry.available_desktops.length) entry.available_desktops = ['Desktop'];
      if (!Array.isArray(entry.use_cases) || !entry.use_cases.length) entry.use_cases = ['Desktop'];
      if (!Array.isArray(entry.target_audience) || !entry.target_audience.length) entry.target_audience = ['Desktop'];
    }
    if (!entry.init_system || entry.init_system === 'Unknown') {
      entry.init_system = family === 'android'
        ? 'Android init'
        : family === 'gentoo'
          ? 'OpenRC'
          : 'systemd';
    }
    if (!entry.popularity_rank || entry.popularity_rank === 0) entry.popularity_rank = 50;
    entry.color = color;
    entry.iso_size = entry.iso_size === null || entry.iso_size === undefined ? 2.3 : entry.iso_size;
    entry.first_release = entry.first_release && entry.first_release !== 'Unknown' ? entry.first_release : 'Unknown';
    entry.latest_version = entry.latest_version && entry.latest_version !== 'Unknown' ? entry.latest_version : 'Unknown';

    entry.description = `${name} is a ${familyName}-family distribution imported from the Linux distribution timeline.`;
    entry.long_description = `This distribution is grouped under the ${familyName} family and was imported from the timeline. It is represented here with app-ready metadata, including package manager, desktop flavor, and family color theme.`;
    entry.pros = [`${familyName}-family lineage`, 'Imported from timeline', 'App-ready metadata'];
    entry.cons = ['Metadata inferred from family rules', 'Release details may need refinement'];
    entry.download = entry.download || '';
    entry.website = entry.website || '';

    changed++;
  }
}
fs.writeFileSync(dataPath, JSON.stringify(distros, null, 2), 'utf8');
console.log(`Updated ${changed} imported distro entries with family metadata.`);
