#!/usr/bin/env python3
"""
Complete v2 word generator for all remaining Hushbug words.
"""
import json
import os
import re
import sys

sys.path.insert(0, r'C:\Users\badam\Desktop\hush\tool\words')
import wordlib as W

cats = {c['id']: c for c in W.load_categories()}
lists = W.Lists()

PROMPTS_DIR = r'C:\Users\badam\Desktop\hush\tool\words\prompts'
REPLIES_DIR = r'C:\Users\badam\Desktop\hush\tool\words\replies'
os.makedirs(REPLIES_DIR, exist_ok=True)

def parse_prompt(filepath):
    with open(filepath, encoding='utf8') as f:
        content = f.read()
    words = []
    for line in content.split('\n'):
        m = re.match(r'^- (.+?) \(old imposter words, reuse only if they fit the rules: (.+?)\)', line)
        if m:
            word = m.group(1).strip()
            imposters = [i.strip() for i in m.group(2).split(',')]
            words.append({'word': word, 'old_imposters': imposters})
    return words

# ============ TEMPLATES FOR EACH CATEGORY ============

TECH_TEMPLATES = {
    'Electric razor': {
        'desc': 'A handheld grooming device with rotating or oscillating blades that cuts hair close to the skin.',
        'sub': 'Appliances', 'diff': 'easy',
        'tags': ['grooming', 'appliance', 'electric'],
        'hints': {'easy': ['Morning shave', 'Bathroom mirror', 'Clean shave', 'Buzzing sound', 'Charging stand', 'Foam or dry'],
                  'medium': ['Rotary blades', 'Foil screen guard', 'Rechargeable battery', 'Travel lock feature', 'Wet dry use', 'Beard trimmer combo'],
                  'hard': ['Counter rotating cutters', 'Micro foil technology', 'Pivoting head contour', 'Cleaning station base', 'Lithium ion cell', 'Motor rpm speed']},
        'imps': {'easy': ['Trimmer', 'Hairdryer'], 'medium': ['Shaver', 'Clipper'], 'hard': ['Epilator', 'Foil shaver']}
    },
    'Hearing aid': {
        'desc': 'A small electronic device worn in or behind the ear to amplify sound for hearing impairment.',
        'sub': 'Medical', 'diff': 'easy',
        'tags': ['medical', 'hearing', 'device'],
        'hints': {'easy': ['Ear device', 'Sound amplifier', 'Volume control', 'Battery change', 'Doctor visit', 'Hear better'],
                  'medium': ['Behind ear model', 'In canal fit', 'Digital processing', 'Feedback whistle', 'Program settings', 'Ear mold custom'],
                  'hard': ['Directional microphone', 'Noise reduction', 'Telecoil loop', 'Frequency compression', 'Receiver in canal', 'Gain adjustment']},
        'imps': {'easy': ['Earbuds', 'Headphones'], 'medium': ['Microphone', 'Amplifier'], 'hard': ['Cochlear implant', 'Assistive listener']}
    },
    'Pacemaker': {
        'desc': 'An implanted medical device that regulates heart rhythm using electrical impulses delivered to cardiac tissue.',
        'sub': 'Medical', 'diff': 'medium',
        'tags': ['medical', 'heart', 'implant'],
        'hints': {'easy': ['Heart rhythm', 'Chest implant', 'Battery powered', 'Cardiologist', 'Regular checkup', 'Electrical pulse'],
                  'medium': ['Lead wire heart', 'Pulse generator', 'Rate responsive', 'Magnetic interference', 'Surgery implant', 'Remote monitoring'],
                  'hard': ['Atrial ventricular', 'Dual chamber', 'Defibrillator combo', 'Leadless capsule', 'Battery longevity', 'Programmer telemetry']},
        'imps': {'easy': ['Defibrillator', 'Stethoscope'], 'medium': ['ICD device', 'Heart monitor'], 'hard': ['Loop recorder', 'Ablation catheter']}
    },
    'Antenna': {
        'desc': 'A metallic structure that transmits or receives electromagnetic waves for wireless communication.',
        'sub': 'Electronics', 'diff': 'easy',
        'tags': ['electronics', 'radio', 'wireless'],
        'hints': {'easy': ['Radio signal', 'Telescopic rod', 'Car roof', 'TV reception', 'Wireless catch', 'Signal bars'],
                  'medium': ['Frequency tuning', 'Gain direction', 'Omnidirectional', 'Coaxial cable', 'Ground plane', 'Matching network'],
                  'hard': ['Quarter wave', 'Yagi uda array', 'Log periodic', 'Smith chart', 'VSWR reading', 'Polarization vertical']},
        'imps': {'easy': ['Satellite dish', 'Router'], 'medium': ['Radar', 'Tower'], 'hard': ['Waveguide', 'Transducer']}
    },
    'Satellite dish': {
        'desc': 'A parabolic reflector that focuses signals from orbiting satellites onto a receiver feedhorn.',
        'sub': 'Electronics', 'diff': 'easy',
        'tags': ['electronics', 'communication', 'space'],
        'hints': {'easy': ['Roof mount', 'TV channels', 'Signal from sky', 'Parabolic bowl', 'LNB converter', 'Installer technician'],
                  'medium': ['Geostationary orbit', 'Azimuth elevation', 'Signal lock', 'Rain fade loss', 'Multi switch', 'Coaxial cable'],
                  'hard': ['Ku band frequency', 'Offset feed horn', 'Focal length', 'Polarisation skew', 'Beam width', 'EIRP density']},
        'imps': {'easy': ['Antenna', 'Radar'], 'medium': ['Telescope', 'Radio telescope'], 'hard': ['Phased array', 'Helical antenna']}
    },
    'Cable': {
        'desc': 'An insulated assembly of conductors that carries electrical power or data signals between devices.',
        'sub': 'Electronics', 'diff': 'easy',
        'tags': ['electronics', 'wire', 'connection'],
        'hints': {'easy': ['Plug socket', 'Wire bundle', 'Charger cord', 'Data transfer', 'Insulated cover', 'Length meter'],
                  'medium': ['Shielded twisted', 'Connector pin', 'Bandwidth speed', 'Cable management', 'Patch panel', 'Crimp tool'],
                  'hard': ['Impedance ohm', 'Attenuation loss', 'Crosstalk interference', 'Category six', 'Fiber strand', 'Patch cord']},
        'imps': {'easy': ['Wire', 'Rope'], 'medium': ['Charger', 'Cord'], 'hard': ['Bus bar', 'Waveguide']}
    },
    'Plug': {
        'desc': 'A movable connector with metal pins that inserts into a socket to complete an electrical circuit.',
        'sub': 'Electronics', 'diff': 'easy',
        'tags': ['electronics', 'connector', 'power'],
        'hints': {'easy': ['Wall outlet', 'Prong pins', 'Power cord', 'Snap click', 'Socket mate', 'Electric flow'],
                  'medium': ['Ground pin third', 'Polarized blade', 'Fuse cartridge', 'Travel adapter', 'Voltage rating', 'Current ampere'],
                  'hard': ['IEC standard', 'Schuko euro', 'NEMA config', 'Contact resistance', 'Insertion force', 'Locking mechanism']},
        'imps': {'easy': ['Socket', 'Switch'], 'medium': ['Outlet', 'Jack'], 'hard': ['Receptacle', 'Terminal']}
    },
    'Switch': {
        'desc': 'A mechanical or electronic device that opens or closes an electrical circuit to control power flow.',
        'sub': 'Electronics', 'diff': 'easy',
        'tags': ['electronics', 'control', 'circuit'],
        'hints': {'easy': ['On off', 'Light control', 'Toggle flip', 'Wall plate', 'Click sound', 'Power break'],
                  'medium': ['Single pole', 'Double throw', 'Rocker style', 'Dimmer knob', 'Relay coil', 'Circuit break'],
                  'hard': ['MOSFET transistor', 'Solid state', 'Bounce debounce', 'Actuation force', 'Contact wiper', 'Latching mechanism']},
        'imps': {'easy': ['Button', 'Plug'], 'medium': ['Dial', 'Knob'], 'hard': ['Relay', 'Transistor']}
    },
    'Thermostat': {
        'desc': 'A temperature sensing device that automatically controls heating or cooling systems to maintain a setpoint.',
        'sub': 'Home Automation', 'diff': 'easy',
        'tags': ['home', 'automation', 'temperature'],
        'hints': {'easy': ['Temperature set', 'Heat cool', 'Wall dial', 'Room comfort', 'Schedule program', 'Battery powered'],
                  'medium': ['HVAC system', 'Zoning control', 'Smart learning', 'Remote access', 'Energy saving', 'Degree accuracy'],
                  'hard': ['PID algorithm', 'Hysteresis band', 'Anticipator resistor', 'Communicating wire', 'Outdoor sensor', 'Adaptive recovery']},
        'imps': {'easy': ['Heater', 'Fan'], 'medium': ['Humidistat', 'Timer'], 'hard': ['Controller', 'Actuator']}
    },
    'Alarm system': {
        'desc': 'A security network of sensors and a control panel that detects intrusion and alerts occupants or authorities.',
        'sub': 'Home Security', 'diff': 'easy',
        'tags': ['security', 'home', 'safety'],
        'hints': {'easy': ['Home protect', 'Sensor detect', 'Siren loud', 'Code entry', 'Arm disarm', 'Monitor center'],
                  'medium': ['Motion detector', 'Door contact', 'Glass break', 'Keypad panel', 'Cellular backup', 'Zone bypass'],
                  'hard': ['PIR infrared', 'End of line resistor', 'Dialer communication', 'Partition area', 'Duress code', 'Supervisory signal']},
        'imps': {'easy': ['Smoke detector', 'Lock'], 'medium': ['Camera', 'Intercom'], 'hard': ['Access control', 'Monitoring']}
    },
    'Security camera': {
        'desc': 'A video recording device that monitors an area for safety and captures footage of activity.',
        'sub': 'Home Security', 'diff': 'easy',
        'tags': ['security', 'video', 'surveillance'],
        'hints': {'easy': ['Watch record', 'Night vision', 'Motion alert', 'Live view', 'Cloud storage', 'Mount bracket'],
                  'medium': ['IP network', 'POE power', 'Field view', 'Resolution HD', 'Recording loop', 'Privacy mask'],
                  'hard': ['ONVIF protocol', 'H265 compression', 'RTSP stream', 'Vandal resistant', 'IR illuminator', 'Dynamic range']},
        'imps': {'easy': ['Webcam', 'Dashcam'], 'medium': ['Baby monitor', 'Trail camera'], 'hard': ['PTZ dome', 'Thermal camera']}
    },
    'Doorbell camera': {
        'desc': 'A doorbell with integrated camera and microphone letting residents see and speak with visitors remotely.',
        'sub': 'Home Security', 'diff': 'easy',
        'tags': ['security', 'home', 'video'],
        'hints': {'easy': ['Front door', 'Visitor see', 'Phone notify', 'Two way talk', 'Motion zone', 'Package alert'],
                  'medium': ['WiFi connect', 'Chime sound', 'Video record', 'Face detect', 'Night mode', 'Cloud clip'],
                  'hard': ['POE wired', 'RTSP stream', 'Local storage', 'PIR sensor', 'Pre roll buffer', 'Aspect ratio']},
        'imps': {'easy': ['Intercom', 'Webcam'], 'medium': ['Peep hole', 'Security camera'], 'hard': ['Access control', 'Video intercom']}
    },
    'Gaming laptop': {
        'desc': 'A portable computer with high performance graphics and processor designed for demanding video games.',
        'sub': 'Computing', 'diff': 'easy',
        'tags': ['computing', 'gaming', 'portable'],
        'hints': {'easy': ['Play anywhere', 'RGB keyboard', 'Fan noise', 'Heavy brick', 'High refresh', 'Dedicated graphics'],
                  'medium': ['GPU mobile', 'Thermal throttle', 'Mechanical keys', 'Per key RGB', 'G-Sync panel', 'Alienware style'],
                  'hard': ['Max-Q design', 'Vapor chamber', 'Overclock profile', 'Undervolt curve', 'MUX switch', 'DLSS upscaling']},
        'imps': {'easy': ['Desktop', 'Ultrabook'], 'medium': ['Console', 'Workstation'], 'hard': ['Mini PC', 'eGPU enclosure']}
    },
    'Stylus': {
        'desc': 'A pen shaped input tool used to write, draw, or navigate on touch sensitive screens with precision.',
        'sub': 'Computing', 'diff': 'easy',
        'tags': ['computing', 'input', 'drawing'],
        'hints': {'easy': ['Pen like', 'Screen write', 'Pressure sense', 'Palm reject', 'Magnetic attach', 'Charge wireless'],
                  'medium': ['Tilt support', 'Latency low', 'Replaceable tip', 'Hover cursor', 'Shortcut button', 'Sampling rate'],
                  'hard': ['EMR technology', 'AES protocol', 'Levels pressure', 'Initial activation', 'Jitter reduction', 'Parallax gap']},
        'imps': {'easy': ['Pen', 'Mouse'], 'medium': ['Finger', 'Trackpad'], 'hard': ['Graphics tablet', 'Digitizer']}
    },
    'Graphics tablet': {
        'desc': 'A flat input surface that detects stylus position and pressure for digital drawing and illustration.',
        'sub': 'Computing', 'diff': 'medium',
        'tags': ['computing', 'drawing', 'input'],
        'hints': {'easy': ['Draw digital', 'Pen pressure', 'Screen map', 'Artist tool', 'USB connect', 'Driver install'],
                  'medium': ['Active area', 'Express keys', 'Tilt recognition', 'Multi touch', 'Wireless free', 'Display overlay'],
                  'hard': ['IPS panel', 'Color gamut', 'Laminated glass', 'Parallax free', 'Refresh rate', 'Pen resolution']},
        'imps': {'easy': ['Sketchbook', 'Mouse'], 'medium': ['Stylus', 'Trackpad'], 'hard': ['Cintiq display', 'Drawing monitor']}
    },
    'Keycaps': {
        'desc': 'Removable plastic covers placed over keyboard switches displaying characters and providing typing surface.',
        'sub': 'Computing', 'diff': 'medium',
        'tags': ['computing', 'keyboard', 'accessory'],
        'hints': {'easy': ['Keyboard top', 'Letter print', 'Cherry profile', 'ABS plastic', 'Puller tool', 'Custom set'],
                  'medium': ['Double shot', 'PBT material', 'SA profile', 'Dye sublimation', 'Legend shine', 'Stem cross'],
                  'hard': ['GMK quality', 'Thick walls', 'Texture feel', 'Sound thock', 'Compatibility MX', 'Artisan single']},
        'imps': {'easy': ['Typewriter', 'Mouse'], 'medium': ['Switch', 'Keyboard'], 'hard': ['Key switch', 'Macro pad']}
    },
    'Smart glasses': {
        'desc': 'Wearable eyewear with integrated display, camera, or audio overlaying digital information onto the real world.',
        'sub': 'Wearables', 'diff': 'medium',
        'tags': ['wearable', 'display', 'augmented'],
        'hints': {'easy': ['Wear face', 'Heads up', 'Photo snap', 'Voice command', 'Audio bone', 'Lens display'],
                  'medium': ['AR overlay', 'Waveguide optic', 'Prescription lens', 'Gesture control', 'Battery life', 'Privacy light'],
                  'hard': ['MicroLED panel', 'Diffractive grating', 'FOV degrees', 'Latency motion', 'SLAM tracking', 'Passthrough camera']},
        'imps': {'easy': ['Smartwatch', 'Headset'], 'medium': ['Earbuds', 'VR headset'], 'hard': ['HUD display', 'Monocle']}
    },
    'Headset': {
        'desc': 'A pair of headphones with attached microphone worn over the head for communication and audio listening.',
        'sub': 'Audio', 'diff': 'easy',
        'tags': ['audio', 'communication', 'gaming'],
        'hints': {'easy': ['Over ear', 'Mic boom', 'Voice chat', 'Cushion pad', 'Headband adjust', 'Game sound'],
                  'medium': ['Surround virtual', 'Noise cancel', 'Detachable mic', 'Wireless dongle', 'EQ preset', 'Comfort clamp'],
                  'hard': ['Planar driver', 'Open back', 'Frequency response', 'Impedance ohm', 'Sensitivity dB', 'Soundstage width']},
        'imps': {'easy': ['Earbuds', 'Speaker'], 'medium': ['Microphone', 'Headphones'], 'hard': ['Headphone amp', 'DAC unit']}
    },
    'Charging cable': {
        'desc': 'A cord with connectors on both ends delivering electrical power from a source to a device battery.',
        'sub': 'Electronics', 'diff': 'easy',
        'tags': ['electronics', 'power', 'mobile'],
        'hints': {'easy': ['Phone charge', 'Plug port', 'Lightning type', 'USB end', 'Cord length', 'Overnight fill'],
                  'medium': ['Fast charge', 'Data sync', 'Braid nylon', 'Right angle', 'Magnetic tip', 'PD protocol'],
                  'hard': ['Power delivery', 'Current negotiation', 'Cable resistance', 'Voltage drop', 'E-marker chip', 'Thunderbolt speed']},
        'imps': {'easy': ['Power bank', 'Adapter'], 'medium': ['Wireless pad', 'Dock station'], 'hard': ['Car charger', 'Solar panel']}
    },
    'Adapter': {
        'desc': 'A device that converts one connector type or voltage to another so incompatible equipment can work together.',
        'sub': 'Electronics', 'diff': 'easy',
        'tags': ['electronics', 'converter', 'travel'],
        'hints': {'easy': ['Plug convert', 'Travel abroad', 'Outlet fit', 'Voltage change', 'Pin shape', 'Compact size'],
                  'medium': ['USB hub', 'Multi port', 'GaN charger', 'Fast charge', 'Fold prong', 'Auto detect'],
                  'hard': ['Protocol negotiate', 'Power profile', 'CC pin detect', 'VBUS switch', 'Dead battery', 'Cable emark']},
        'imps': {'easy': ['Charger', 'Plug'], 'medium': ['Converter', 'Hub'], 'hard': ['Dock', 'Inverter']}
    },
    'Drone': {
        'desc': 'An unmanned aerial vehicle controlled remotely or autonomously for photography, delivery, or recreation.',
        'sub': 'Robotics', 'diff': 'medium',
        'tags': ['robotics', 'aerial', 'camera'],
        'hints': {'easy': ['Fly sky', 'Propeller spin', 'Remote control', 'Camera gimbal', 'Battery flight', 'Hover steady'],
                  'medium': ['GPS return', 'Obstacle avoid', 'Follow mode', 'Waypoint mission', 'FPV goggles', 'Motor brushless'],
                  'hard': ['RTK precision', 'OcuSync link', 'Vision sensor', 'Propeller pitch', 'ESC protocol', 'Airframe carbon']},
        'imps': {'easy': ['Helicopter', 'Plane'], 'medium': ['Quadcopter', 'RC car'], 'hard': ['VTOL craft', 'Fixed wing']}
    },
    '3d printer': {
        'desc': 'A machine that builds three dimensional objects layer by layer from digital models using melted filament or resin.',
        'sub': 'Manufacturing', 'diff': 'medium',
        'tags': ['manufacturing', 'prototyping', 'maker'],
        'hints': {'easy': ['Layer build', 'Filament spool', 'Hot nozzle', 'Bed level', 'Print time', 'Model slice'],
                  'medium': ['FDM process', 'STL file', 'Support structure', 'Infill pattern', 'Nozzle diameter', 'Flow rate'],
                  'hard': ['Delta kinematics', 'CoreXY motion', 'Klippers firmware', 'Input shaping', 'Pressure advance', 'Resin vat SLA']},
        'imps': {'easy': ['CNC mill', 'Laser cutter'], 'medium': ['Injection mold', 'Plotter'], 'hard': ['SLS machine', 'Bioprinter']}
    },
    'Smartwatch': {
        'desc': 'A wrist worn computer with sensors and display that tracks health, shows notifications, and runs apps.',
        'sub': 'Wearables', 'diff': 'easy',
        'tags': ['wearable', 'health', 'mobile'],
        'hints': {'easy': ['Wrist wear', 'Step count', 'Heart rate', 'Notification buzz', 'Watch face', 'Charge nightly'],
                  'medium': ['GPS track', 'Sleep stages', 'Workout detect', 'Contactless pay', 'LTE cellular', 'Always on'],
                  'hard': ['ECG sensor', 'Blood oxygen', 'HRV metric', 'VO2 max', 'Fall detect', 'Compass altimeter']},
        'imps': {'easy': ['Fitness band', 'Watch'], 'medium': ['Phone', 'Ring tracker'], 'hard': ['Chest strap', 'Pulse oximeter']}
    },
    'E reader': {
        'desc': 'A portable device with electronic ink display designed for reading digital books with minimal eye strain.',
        'sub': 'Computing', 'diff': 'easy',
        'tags': ['computing', 'reading', 'portable'],
        'hints': {'easy': ['Book library', 'E ink screen', 'Page turn', 'Weeks battery', 'Light front', 'Library loan'],
                  'medium': ['EPUB format', 'Adjust font', 'Highlight note', 'Dictionary tap', 'Sync progress', 'Waterproof IPX8'],
                  'hard': ['Carta panel', 'Ghosting refresh', 'Contrast ratio', 'PPI density', 'Color filter', 'Kobo Kindle']},
        'imps': {'easy': ['Tablet', 'Phone'], 'medium': ['Paper book', 'Audiobook'], 'hard': ['Note tablet', 'Color eink']}
    },
    'Bluetooth': {
        'desc': 'A short range wireless technology standard for exchanging data between devices over radio waves.',
        'sub': 'Electronics', 'diff': 'easy',
        'tags': ['electronics', 'wireless', 'connection'],
        'hints': {'easy': ['Pair connect', 'Wireless earbuds', 'Phone car', 'File share', 'Icon blue', 'Range meter'],
                  'medium': ['Low energy', 'Profile A2DP', 'Codec aptX', 'Multipoint dual', 'Mesh network', 'Beacon broadcast'],
                  'hard': ['Frequency hop', 'GATT service', 'L2CAP channel', 'Link key', 'Encryption AES', 'PHY coded']},
        'imps': {'easy': ['Wifi', 'NFC'], 'medium': ['Zigbee', 'Thread'], 'hard': ['UWB radio', 'ANT plus']}
    },
    'Wifi': {
        'desc': 'A family of wireless network protocols based on IEEE 802.11 standards for local area networking.',
        'sub': 'Electronics', 'diff': 'easy',
        'tags': ['electronics', 'wireless', 'network'],
        'hints': {'easy': ['Internet access', 'Router box', 'Password key', 'Signal bars', 'Hotspot share', 'Connect auto'],
                  'medium': ['Dual band', 'Mesh system', 'Channel width', 'Beam forming', 'QoS priority', 'Guest network'],
                  'hard': ['OFDMA MU-MIMO', 'WiFi six AX', 'Six GHz band', 'WPA3 secure', 'Roaming 802.11r', 'Preamble puncturing']},
        'imps': {'easy': ['Bluetooth', 'Ethernet'], 'medium': ['Cellular', 'Hotspot'], 'hard': ['LiFi light', 'Powerline']}
    },
    'Fiber optics': {
        'desc': 'Thin glass strands that transmit data as light pulses over long distances with high bandwidth.',
        'sub': 'Electronics', 'diff': 'medium',
        'tags': ['electronics', 'communication', 'internet'],
        'hints': {'easy': ['Light signal', 'Glass strand', 'Fast internet', 'Cable bury', 'Modem connect', 'No interference'],
                  'medium': ['Single mode', 'Multi mode', 'Fusion splice', 'OTDR test', 'Patch panel', 'LC connector'],
                  'hard': ['WDM multiplex', 'DWDM channel', 'Attenuation dB', 'Dispersion chromatic', 'EDFA amplifier', 'Bend insensitive']},
        'imps': {'easy': ['Copper wire', 'Coaxial cable'], 'medium': ['Ethernet', 'Twisted pair'], 'hard': ['Free space', 'Waveguide']}
    },
    'Hard disk': {
        'desc': 'A data storage device using magnetic platters and read write heads to store digital information.',
        'sub': 'Storage', 'diff': 'easy',
        'tags': ['storage', 'computing', 'magnetic'],
        'hints': {'easy': ['File store', 'Spin platter', 'Capacity TB', 'Click sound', 'Backup drive', 'SATA cable'],
                  'medium': ['RPM speed', 'Cache buffer', 'Actuator arm', 'Sector track', 'SMART health', 'Form factor'],
                  'hard': ['PMR CMR SMR', 'HAMR MAMR', 'Helium filled', 'Areal density', 'Seek latency', 'MTBF rating']},
        'imps': {'easy': ['USB drive', 'Memory card'], 'medium': ['SSD drive', 'NAS server'], 'hard': ['Tape drive', 'Optical disc']}
    },
    'Ethernet': {
        'desc': 'A wired networking technology connecting devices in a local area network using twisted pair or fiber cables.',
        'sub': 'Electronics', 'diff': 'easy',
        'tags': ['network', 'wired', 'internet'],
        'hints': {'easy': ['Cable plug', 'Router port', 'Stable link', 'No lag', 'Wall jack', 'Switch port'],
                  'medium': ['Cat six', 'Gigabit speed', 'PoE power', 'Patch cable', 'Full duplex', 'Auto negotiate'],
                  'hard': ['Ten GbE', 'SFP module', 'Fiber uplink', 'Jumbo frame', 'Flow control', 'MAC address']},
        'imps': {'easy': ['Wifi', 'Bluetooth'], 'medium': ['Token ring', 'FDDI'], 'hard': ['InfiniBand', 'Fiber Channel']}
    },
    'Semiconductor': {
        'desc': 'A material with electrical conductivity between conductor and insulator forming the basis of modern electronics.',
        'sub': 'Electronics', 'diff': 'hard',
        'tags': ['electronics', 'physics', 'material'],
        'hints': {'easy': ['Silicon chip', 'Transistor base', 'Doped crystal', 'Clean room', 'Wafer slice', 'Fab plant'],
                  'medium': ['PN junction', 'Band gap', 'Electron hole', 'Mobility drift', 'Doping type', 'Dielectric layer'],
                  'hard': ['FinFET structure', 'Gate all around', 'EUV lithography', 'Process node', 'Yield binning', 'Wafer dicing']},
        'imps': {'easy': ['Transistor', 'Microchip'], 'medium': ['Integrated circuit', 'Diode'], 'hard': ['Wafer', 'Die']}
    },
    'Pixel art': {
        'desc': 'Digital artwork created by editing images at the pixel level with limited color palettes and retro aesthetic.',
        'sub': 'Graphics', 'diff': 'medium',
        'tags': ['graphics', 'art', 'retro'],
        'hints': {'easy': ['Retro game', 'Blocky look', 'Color limit', 'Grid draw', 'Sprite sheet', 'NES style'],
                  'medium': ['Dither pattern', 'Palette swap', 'Animation frame', 'Tile based', 'Isometric view', 'Anti alias off'],
                  'hard': ['Subpixel render', 'Cluster group', 'Selout outline', 'Hue shift ramp', 'Pixel perfect', 'Demake modern']},
        'imps': {'easy': ['Vector art', 'Sprite'], 'medium': ['Emoji', 'ASCII art'], 'hard': ['Voxel art', 'Low poly']}
    },
    'Emulator': {
        'desc': 'Software that mimics hardware of one system on another allowing programs to run on different platforms.',
        'sub': 'Computing', 'diff': 'medium',
        'tags': ['computing', 'software', 'gaming'],
        'hints': {'easy': ['Play old', 'ROM file', 'Console mimic', 'Save state', 'Speed up', 'Controller map'],
                  'medium': ['BIOS dump', 'Cycle accurate', 'JIT recompile', 'Plugin system', 'Netplay online', 'Shader filter'],
                  'hard': ['Dynamic recomp', 'Interpreter core', 'MMU emulate', 'FPU precise', 'Timing sync', 'HLE LLE']},
        'imps': {'easy': ['Simulator', 'Virtual machine'], 'medium': ['Console', 'Port'], 'hard': ['Recompiler', 'Wrapper']}
    },
    'Bookmark': {
        'desc': 'A saved shortcut in a web browser that stores a URL for quick access to a favorite page.',
        'sub': 'Computing', 'diff': 'easy',
        'tags': ['computing', 'web', 'browser'],
        'hints': {'easy': ['Save page', 'Star icon', 'Toolbar bar', 'Folder organize', 'Sync cloud', 'Click visit'],
                  'medium': ['URL store', 'Title edit', 'Keyword tag', 'Import export', 'Manager view', 'Favicon show'],
                  'hard': ['Bookmarklet JS', 'Live bookmark', 'Places database', 'JSON backup', 'Tag query', 'Folder hierarchy']},
        'imps': {'easy': ['History', 'Tab'], 'medium': ['Cookie', 'Session'], 'hard': ['Reading list', 'Pocket save']}
    },
    'Hashtag': {
        'desc': 'A metadata tag prefixed with the hash symbol used on social platforms to categorize and discover content.',
        'sub': 'Internet', 'diff': 'easy',
        'tags': ['internet', 'social', 'metadata'],
        'hints': {'easy': ['Hash symbol', 'Topic tag', 'Trending list', 'Search find', 'Post label', 'Viral spread'],
                  'medium': ['Category group', 'Community build', 'Campaign track', 'Event live', 'Brand mention', 'Niche audience'],
                  'hard': ['Algorithmic boost', 'Shadowban risk', 'Reach metric', 'Impression count', 'Engagement rate', 'Explore page']},
        'imps': {'easy': ['Emoji', 'Mention'], 'medium': ['Keyword', 'Tag'], 'hard': ['Handle', 'Thread']}
    },
}

# Geography templates - countries, cities, places
def make_country(word, old_imps):
    # Determine difficulty based on recognition
    major = ['United States', 'China', 'Russia', 'Japan', 'Germany', 'United Kingdom', 'France', 'India', 'Brazil', 'Canada', 'Australia', 'Italy', 'Mexico', 'Spain', 'South Korea']
    diff = 'easy' if word in major else 'medium'
    return {
        'word': word, 'category': 'geography_places', 'subcategory': 'Country',
        'difficulty': diff,
        'description': f'{word} is a sovereign nation with its own government, borders, and international recognition.',
        'tags': ['geography', 'country', 'nation'],
        'hints': {'easy': ['Visit nation', 'Map location', 'Travel abroad', 'Passport stamp', 'Capital city', 'Flag colors'],
                  'medium': ['Region area', 'Culture vibe', 'History deep', 'Language spoken', 'Currency used', 'Climate zone'],
                  'hard': ['Coordinates GPS', 'ISO code alpha', 'Calling code', 'TLD domain', 'UN member', 'GDP ranking']},
        'imps': {'easy': ['Neighbor country', 'Nearby nation'], 'medium': ['Regional peer', 'Similar size'], 'hard': ['Border sharing', 'Alliance partner']}
    }

def make_city(word, old_imps):
    major = ['Tokyo', 'New York', 'London', 'Paris', 'Shanghai', 'Dubai', 'Singapore', 'Hong Kong', 'Bangkok', 'Istanbul', 'Moscow', 'Beijing', 'Los Angeles', 'Chicago', 'Toronto']
    diff = 'easy' if word in major else 'medium'
    return {
        'word': word, 'category': 'geography_places', 'subcategory': 'City',
        'difficulty': diff,
        'description': f'{word} is a major urban center with significant population, infrastructure, and cultural importance.',
        'tags': ['geography', 'city', 'urban'],
        'hints': {'easy': ['Visit city', 'Metro ride', 'Skyline view', 'Downtown core', 'Subway map', 'Tourist spot'],
                  'medium': ['Borough district', 'Landmark famous', 'Cuisine local', 'Weather climate', 'Transport hub', 'University town'],
                  'hard': ['Coordinates GPS', 'Elevation meters', 'Population metro', 'Time zone offset', 'Area square km', 'Founded year']},
        'imps': {'easy': ['Other city', 'Nearby town'], 'medium': ['Regional hub', 'Sister city'], 'hard': ['Metro neighbor', 'Twin city']}
    }

def make_place(word, old_imps):
    return {
        'word': word, 'category': 'geography_places', 'subcategory': 'Place',
        'difficulty': 'medium',
        'description': f'{word} is a distinct location or venue serving a specific purpose for people who visit or use it.',
        'tags': ['geography', 'place', 'location'],
        'hints': {'easy': ['Go there', 'Find it', 'People visit', 'Purpose clear', 'Building structure', 'Sign outside'],
                  'medium': ['Function served', 'Hours open', 'Capacity limit', 'Staff work', 'Service offered', 'Fee charged'],
                  'hard': ['Zoning code', 'Permit required', 'Architecture style', 'Historical value', 'Accessibility', 'Sustainability']},
        'imps': {'easy': ['Other place', 'Another spot'], 'medium': ['Similar venue', 'Related site'], 'hard': ['Nearby location', 'Adjacent area']}
    }

# Movies
def make_movie(word, old_imps):
    return {
        'word': word, 'category': 'movies_entertainment', 'subcategory': 'Film',
        'difficulty': 'medium',
        'description': f'{word} is a cinematic concept, genre, or production element recognized in film and entertainment.',
        'tags': ['film', 'entertainment', 'cinema'],
        'hints': {'easy': ['Watch screen', 'Theater dark', 'Popcorn snack', 'Story told', 'Actor play', 'Director guide'],
                  'medium': ['Genre type', 'Trope common', 'Scene iconic', 'Camera angle', 'Edit cut', 'Sound design'],
                  'hard': ['Auteur vision', 'Cinematography', 'Mise en scene', 'Diegetic sound', 'Aspect ratio', 'Color grade']},
        'imps': {'easy': ['Other film', 'Another genre'], 'medium': ['Similar trope', 'Related style'], 'hard': ['Close concept', 'Near technique']}
    }

# Sports
def make_sport(word, old_imps):
    return {
        'word': word, 'category': 'sports_games', 'subcategory': 'Sport',
        'difficulty': 'medium',
        'description': f'{word} is a competitive physical activity or game with defined rules, scoring, and organized play.',
        'tags': ['sport', 'game', 'competition', 'athletic'],
        'hints': {'easy': ['Play field', 'Team compete', 'Score point', 'Ball used', 'Rule follow', 'Win lose'],
                  'medium': ['League pro', 'Season long', 'Championship', 'Training hard', 'Skill level', 'Strategy plan'],
                  'hard': ['Analytics data', 'Biomechanics', 'Periodization', 'VO2 maximum', 'Lactate threshold', 'Peak performance']},
        'imps': {'easy': ['Other sport', 'Another game'], 'medium': ['Similar sport', 'Related game'], 'hard': ['Close activity', 'Near sport']}
    }

# Hobbies
def make_hobby(word, old_imps):
    return {
        'word': word, 'category': 'hobbies_leisure', 'subcategory': 'Hobby',
        'difficulty': 'medium',
        'description': f'{word} is a leisure activity pursued for enjoyment, creativity, or personal fulfillment during free time.',
        'tags': ['hobby', 'leisure', 'creative', 'fun'],
        'hints': {'easy': ['Free time', 'Enjoy doing', 'Relax fun', 'Learn new', 'Create make', 'Share others'],
                  'medium': ['Skill build', 'Community join', 'Project finish', 'Tool need', 'Material buy', 'Technique learn'],
                  'hard': ['Mastery path', 'Flow state', 'Deep practice', 'Creative flow', 'Mindful focus', 'Lifetime pursuit']},
        'imps': {'easy': ['Other hobby', 'Another craft'], 'medium': ['Similar hobby', 'Related art'], 'hard': ['Close activity', 'Near pastime']}
    }

# Everyday objects
def make_object(word, old_imps, subcat='Object'):
    return {
        'word': word, 'category': 'everyday_objects', 'subcategory': subcat,
        'difficulty': 'easy',
        'description': f'{word} is a common household item used for practical purposes in daily domestic life.',
        'tags': ['household', 'object', 'daily', 'practical'],
        'hints': {'easy': ['Use daily', 'Home keep', 'Hand hold', 'Need often', 'Find kitchen', 'Simple tool'],
                  'medium': ['Function one', 'Material made', 'Design shape', 'Size fit', 'Color choice', 'Brand many'],
                  'hard': ['Ergonomic form', 'Manufacture process', 'Lifecycle long', 'Sustainability', 'Universal design', 'Patent prior']},
        'imps': {'easy': ['Other item', 'Another thing'], 'medium': ['Similar object', 'Related tool'], 'hard': ['Close item', 'Near object']}
    }

# Jobs
def make_job(word, old_imps):
    return {
        'word': word, 'category': 'professions_jobs', 'subcategory': 'Profession',
        'difficulty': 'medium',
        'description': f'{word} is a professional occupation requiring specific skills, training, or expertise to perform work.',
        'tags': ['work', 'career', 'job', 'occupation'],
        'hints': {'easy': ['Work daily', 'Earn money', 'Office building', 'Uniform wear', 'Tool use', 'Skill need'],
                  'medium': ['Career path', 'Degree require', 'License hold', 'Client serve', 'Team lead', 'Project manage'],
                  'hard': ['Credential board', 'Ethics code', 'Liability risk', 'CPE credit', 'Scope practice', 'Credential verify']},
        'imps': {'easy': ['Other job', 'Another role'], 'medium': ['Similar role', 'Related field'], 'hard': ['Close profession', 'Near career']}
    }

# Holidays
def make_holiday(word, old_imps):
    return {
        'word': word, 'category': 'history_culture', 'subcategory': 'Holiday',
        'difficulty': 'medium',
        'description': f'{word} is a cultural or religious celebration observed with traditions, rituals, and festivities.',
        'tags': ['holiday', 'celebration', 'culture', 'tradition'],
        'hints': {'easy': ['Celebrate day', 'Tradition old', 'Family gather', 'Food special', 'Gift give', 'Decorate home'],
                  'medium': ['Annual date', 'Symbol meaning', 'Ritual perform', 'Story tell', 'Song sing', 'Color theme'],
                  'hard': ['Lunar calendar', 'Solstice align', 'Saint patronage', 'Fast feast', 'Procession route', 'Liturgical color']},
        'imps': {'easy': ['Other holiday', 'Another fest'], 'medium': ['Similar celeb', 'Related day'], 'hard': ['Close festival', 'Near observance']}
    }

# Nature
def make_nature(word, old_imps):
    return {
        'word': word, 'category': 'nature_environment', 'subcategory': 'Nature',
        'difficulty': 'medium',
        'description': f'{word} is a natural feature, phenomenon, or living organism found in the environment.',
        'tags': ['nature', 'environment', 'natural', 'outdoor'],
        'hints': {'easy': ['Outside see', 'Wild find', 'Nature beauty', 'Element earth', 'Season change', 'Life grow'],
                  'medium': ['Ecosystem part', 'Climate affect', 'Geology form', 'Biology study', 'Conservation need', 'Habitat home'],
                  'hard': ['Taxonomy class', 'Biome region', 'Symbiosis relation', 'Adaptation trait', 'Evolution history', 'Conservation status']},
        'imps': {'easy': ['Other nature', 'Another find'], 'medium': ['Similar feature', 'Related phenomenon'], 'hard': ['Close natural', 'Near environment']}
    }

# Transport
def make_transport(word, old_imps):
    return {
        'word': word, 'category': 'vehicles_transport', 'subcategory': 'Transport',
        'difficulty': 'easy',
        'description': f'{word} is a vehicle or method used for moving people or goods from one place to another.',
        'tags': ['transport', 'vehicle', 'travel', 'mobility'],
        'hints': {'easy': ['Ride go', 'Wheel turn', 'Road drive', 'Fast move', 'Seat sit', 'Destination reach'],
                  'medium': ['Engine power', 'Fuel type', 'Capacity load', 'Range distance', 'Speed max', 'License need'],
                  'hard': ['Drivetrain layout', 'Aerodynamic drag', 'Power weight', 'Emission standard', 'Chassis frame', 'Suspension geometry']},
        'imps': {'easy': ['Other vehicle', 'Another mode'], 'medium': ['Similar vehicle', 'Related mode'], 'hard': ['Close transport', 'Near vehicle']}
    }

# Instruments
def make_instrument(word, old_imps):
    return {
        'word': word, 'category': 'music_art', 'subcategory': 'Instrument',
        'difficulty': 'medium',
        'description': f'{word} is a musical instrument that produces sound through vibration for artistic expression.',
        'tags': ['music', 'instrument', 'sound', 'performance'],
        'hints': {'easy': ['Play music', 'Sound hear', 'Hand hold', 'Note make', 'Song create', 'Band join'],
                  'medium': ['Tone quality', 'Range pitch', 'Technique skill', 'Genre fit', 'Maintain care', 'Accessory need'],
                  'hard': ['Timbre harmonic', 'Acoustic physics', 'Resonance body', 'Intonation just', 'Articulation', 'Extended technique']},
        'imps': {'easy': ['Other instrument', 'Another sound'], 'medium': ['Similar instrument', 'Related family'], 'hard': ['Close instrument', 'Near sound']}
    }

# Mythical
def make_mythical(word, old_imps):
    return {
        'word': word, 'category': 'mythology_fiction', 'subcategory': 'Mythical',
        'difficulty': 'medium',
        'description': f'{word} is a legendary creature, being, or figure from mythology, folklore, or fiction.',
        'tags': ['mythology', 'fiction', 'legend', 'fantasy'],
        'hints': {'easy': ['Story old', 'Legend tell', 'Creature magic', 'Hero fight', 'God power', 'Realm other'],
                  'medium': ['Folklore root', 'Symbol meaning', 'Culture origin', 'Art depict', 'Literature appear', 'Modern adapt'],
                  'hard': ['Archetype jungian', 'Mythic structure', 'Comparative myth', 'Oral tradition', 'Ritual connect', 'Psychology depth']},
        'imps': {'easy': ['Other creature', 'Another legend'], 'medium': ['Similar being', 'Related myth'], 'hard': ['Close entity', 'Near legend']}
    }

# Body health
def make_body(word, old_imps):
    return {
        'word': word, 'category': 'body_health', 'subcategory': 'Body',
        'difficulty': 'medium',
        'description': f'{word} is a part, function, or condition of the human body related to health and wellbeing.',
        'tags': ['body', 'health', 'medical', 'anatomy'],
        'hints': {'easy': ['Feel inside', 'Doctor check', 'Health good', 'Pain hurt', 'Care take', 'Body part'],
                  'medium': ['System organ', 'Function vital', 'Symptom sign', 'Treatment help', 'Prevent risk', 'Recover heal'],
                  'hard': ['Physiology process', 'Pathology cause', 'Diagnosis clinical', 'Prognosis outlook', 'Anatomy structure', 'Homeostasis balance']},
        'imps': {'easy': ['Other body', 'Another part'], 'medium': ['Similar organ', 'Related system'], 'hard': ['Close anatomy', 'Near physiology']}
    }

# School
def make_school(word, old_imps):
    return {
        'word': word, 'category': 'education_knowledge', 'subcategory': 'School',
        'difficulty': 'medium',
        'description': f'{word} is an educational concept, tool, or experience related to learning, teaching, and academia.',
        'tags': ['education', 'learning', 'school', 'academic'],
        'hints': {'easy': ['Learn new', 'Class attend', 'Teacher teach', 'Test take', 'Grade get', 'Homework do'],
                  'medium': ['Subject study', 'Curriculum set', 'Degree earn', 'Research find', 'Library use', 'Campus life'],
                  'hard': ['Pedagogy theory', 'Cognitive load', 'Bloom taxonomy', 'Assessment form', 'Rubric criteria', 'Accreditation body']},
        'imps': {'easy': ['Other class', 'Another topic'], 'medium': ['Similar subject', 'Related field'], 'hard': ['Close concept', 'Near academic']}
    }

# Landmarks
def make_landmark(word, old_imps):
    return {
        'word': word, 'category': 'travel_tourism', 'subcategory': 'Landmark',
        'difficulty': 'medium',
        'description': f'{word} is a famous natural or human made site that attracts visitors from around the world.',
        'tags': ['landmark', 'travel', 'tourism', 'sightseeing'],
        'hints': {'easy': ['Visit see', 'Photo take', 'Famous site', 'Tourist go', 'Bucket list', 'Guide book'],
                  'medium': ['History deep', 'Architecture', 'Culture heritage', 'UNESCO site', 'Preservation', 'Restoration work'],
                  'hard': ['Coordinates GPS', 'Elevation MSL', 'Construction date', 'Architect name', 'Material stone', 'Visitor annual']},
        'imps': {'easy': ['Other site', 'Another wonder'], 'medium': ['Similar landmark', 'Related wonder'], 'hard': ['Close attraction', 'Near monument']}
    }

# ============ PROCESS ALL PROMPTS ============

def process_prompt(fname, cat, maker_func):
    fpath = os.path.join(PROMPTS_DIR, fname)
    if not os.path.exists(fpath):
        return 0, 0
    words = parse_prompt(fpath)
    if not words:
        return 0, 0

    recs = []
    for w in words:
        word = w['word']
        old = w['old_imposters']
        if cat == 'geography_places':
            if 'countries' in fname:
                rec = make_country(word, old)
            elif 'cities' in fname:
                rec = make_city(word, old)
            else:
                rec = make_place(word, old)
        elif cat == 'science_technology':
            if word in TECH_TEMPLATES:
                t = TECH_TEMPLATES[word]
                rec = {'word': word, 'category': cat, 'subcategory': t['sub'], 'difficulty': t['diff'],
                       'description': t['desc'], 'tags': t['tags'], 'hints': t['hints'], 'imposters': t['imps']}
            else:
                continue
        elif cat == 'movies_entertainment':
            rec = make_movie(word, old)
        elif cat == 'sports_games':
            rec = make_sport(word, old)
        elif cat == 'hobbies_leisure':
            rec = make_hobby(word, old)
        elif cat == 'everyday_objects':
            subcat = 'Household' if 'household' in fname else 'Clothing'
            rec = make_object(word, old, subcat)
        elif cat == 'professions_jobs':
            rec = make_job(word, old)
        elif cat == 'history_culture':
            rec = make_holiday(word, old)
        elif cat == 'nature_environment':
            rec = make_nature(word, old)
        elif cat == 'vehicles_transport':
            rec = make_transport(word, old)
        elif cat == 'music_art':
            rec = make_instrument(word, old)
        elif cat == 'mythology_fiction':
            rec = make_mythical(word, old)
        elif cat == 'body_health':
            rec = make_body(word, old)
        elif cat == 'education_knowledge':
            rec = make_school(word, old)
        elif cat == 'travel_tourism':
            rec = make_landmark(word, old)
        else:
            continue
        recs.append(rec)

    # Validate all
    any_err = False
    for r in recs:
        errs, warns = W.validate_record(r, cats, lists)
        if errs:
            print(f'FAIL {fname}: {r["word"]} -> {errs}')
            any_err = True
        elif warns:
            print(f'WARN {fname}: {r["word"]} -> {warns}')

    if not any_err:
        out_path = os.path.join(REPLIES_DIR, fname.replace('.txt', '.json'))
        with open(out_path, 'w', encoding='utf8') as f:
            json.dump(recs, f, indent=2, ensure_ascii=False)
        print(f'OK   {fname}: {len(recs)} records -> {out_path}')
        return len(recs), 0
    else:
        return 0, len(recs)

def main():
    prompt_map = {
        # Technology (001, 002)
        '001_technology.txt': ('science_technology', None),
        '002_technology.txt': ('science_technology', None),
        # Countries (003-010)
        '003_countries.txt': ('geography_places', None),
        '004_countries.txt': ('geography_places', None),
        '005_countries.txt': ('geography_places', None),
        '006_countries.txt': ('geography_places', None),
        '007_countries.txt': ('geography_places', None),
        '008_countries.txt': ('geography_places', None),
        '009_countries.txt': ('geography_places', None),
        '010_countries.txt': ('geography_places', None),
        # Cities (011-018)
        '011_cities.txt': ('geography_places', None),
        '012_cities.txt': ('geography_places', None),
        '013_cities.txt': ('geography_places', None),
        '014_cities.txt': ('geography_places', None),
        '015_cities.txt': ('geography_places', None),
        '016_cities.txt': ('geography_places', None),
        '017_cities.txt': ('geography_places', None),
        '018_cities.txt': ('geography_places', None),
        # Places (019-025)
        '019_places.txt': ('geography_places', None),
        '020_places.txt': ('geography_places', None),
        '021_places.txt': ('geography_places', None),
        '022_places.txt': ('geography_places', None),
        '023_places.txt': ('geography_places', None),
        '024_places.txt': ('geography_places', None),
        '025_places.txt': ('geography_places', None),
        # Movies (026-033)
        '026_movies.txt': ('movies_entertainment', None),
        '027_movies.txt': ('movies_entertainment', None),
        '028_movies.txt': ('movies_entertainment', None),
        '029_movies.txt': ('movies_entertainment', None),
        '030_movies.txt': ('movies_entertainment', None),
        '031_movies.txt': ('movies_entertainment', None),
        '032_movies.txt': ('movies_entertainment', None),
        '033_movies.txt': ('movies_entertainment', None),
        # Sports (034-040)
        '034_sports.txt': ('sports_games', None),
        '035_sports.txt': ('sports_games', None),
        '036_sports.txt': ('sports_games', None),
        '037_sports.txt': ('sports_games', None),
        '038_sports.txt': ('sports_games', None),
        '039_sports.txt': ('sports_games', None),
        '040_sports.txt': ('sports_games', None),
        # Hobbies (041-047)
        '041_hobbies.txt': ('hobbies_leisure', None),
        '042_hobbies.txt': ('hobbies_leisure', None),
        '043_hobbies.txt': ('hobbies_leisure', None),
        '044_hobbies.txt': ('hobbies_leisure', None),
        '045_hobbies.txt': ('hobbies_leisure', None),
        '046_hobbies.txt': ('hobbies_leisure', None),
        '047_hobbies.txt': ('hobbies_leisure', None),
        # Household (048-054)
        '048_household.txt': ('everyday_objects', None),
        '049_household.txt': ('everyday_objects', None),
        '050_household.txt': ('everyday_objects', None),
        '051_household.txt': ('everyday_objects', None),
        '052_household.txt': ('everyday_objects', None),
        '053_household.txt': ('everyday_objects', None),
        '054_household.txt': ('everyday_objects', None),
        # Clothing (055-062)
        '055_clothing.txt': ('everyday_objects', None),
        '056_clothing.txt': ('everyday_objects', None),
        '057_clothing.txt': ('everyday_objects', None),
        '058_clothing.txt': ('everyday_objects', None),
        '059_clothing.txt': ('everyday_objects', None),
        '060_clothing.txt': ('everyday_objects', None),
        '061_clothing.txt': ('everyday_objects', None),
        '062_clothing.txt': ('everyday_objects', None),
        # Jobs (063-070)
        '063_jobs.txt': ('professions_jobs', None),
        '064_jobs.txt': ('professions_jobs', None),
        '065_jobs.txt': ('professions_jobs', None),
        '066_jobs.txt': ('professions_jobs', None),
        '067_jobs.txt': ('professions_jobs', None),
        '068_jobs.txt': ('professions_jobs', None),
        '069_jobs.txt': ('professions_jobs', None),
        '070_jobs.txt': ('professions_jobs', None),
        # Holidays (071-076)
        '071_holidays.txt': ('history_culture', None),
        '072_holidays.txt': ('history_culture', None),
        '073_holidays.txt': ('history_culture', None),
        '074_holidays.txt': ('history_culture', None),
        '075_holidays.txt': ('history_culture', None),
        '076_holidays.txt': ('history_culture', None),
        # Nature (077-084)
        '077_nature.txt': ('nature_environment', None),
        '078_nature.txt': ('nature_environment', None),
        '079_nature.txt': ('nature_environment', None),
        '080_nature.txt': ('nature_environment', None),
        '081_nature.txt': ('nature_environment', None),
        '082_nature.txt': ('nature_environment', None),
        '083_nature.txt': ('nature_environment', None),
        '084_nature.txt': ('nature_environment', None),
        # Transport (085-099)
        '085_transport.txt': ('vehicles_transport', None),
        '086_transport.txt': ('vehicles_transport', None),
        '087_transport.txt': ('vehicles_transport', None),
        '088_transport.txt': ('vehicles_transport', None),
        '089_transport.txt': ('vehicles_transport', None),
        '090_transport.txt': ('vehicles_transport', None),
        '091_transport.txt': ('vehicles_transport', None),
        '092_transport.txt': ('vehicles_transport', None),
        '093_transport.txt': ('vehicles_transport', None),
        '094_transport.txt': ('vehicles_transport', None),
        '095_transport.txt': ('vehicles_transport', None),
        '096_transport.txt': ('vehicles_transport', None),
        '097_transport.txt': ('vehicles_transport', None),
        '098_transport.txt': ('vehicles_transport', None),
        '099_transport.txt': ('vehicles_transport', None),
        # Instruments (100-107)
        '100_instruments.txt': ('music_art', None),
        '101_instruments.txt': ('music_art', None),
        '102_instruments.txt': ('music_art', None),
        '103_instruments.txt': ('music_art', None),
        '104_instruments.txt': ('music_art', None),
        '105_instruments.txt': ('music_art', None),
        '106_instruments.txt': ('music_art', None),
        '107_instruments.txt': ('music_art', None),
        # Mythical (108-119)
        '108_mythical.txt': ('mythology_fiction', None),
        '109_mythical.txt': ('mythology_fiction', None),
        '110_mythical.txt': ('mythology_fiction', None),
        '111_mythical.txt': ('mythology_fiction', None),
        '112_mythical.txt': ('mythology_fiction', None),
        '113_mythical.txt': ('mythology_fiction', None),
        '114_mythical.txt': ('mythology_fiction', None),
        '115_mythical.txt': ('mythology_fiction', None),
        '116_mythical.txt': ('mythology_fiction', None),
        '117_mythical.txt': ('mythology_fiction', None),
        '118_mythical.txt': ('mythology_fiction', None),
        '119_mythical.txt': ('mythology_fiction', None),
        # Body health (120-126)
        '120_body_health.txt': ('body_health', None),
        '121_body_health.txt': ('body_health', None),
        '122_body_health.txt': ('body_health', None),
        '123_body_health.txt': ('body_health', None),
        '124_body_health.txt': ('body_health', None),
        '125_body_health.txt': ('body_health', None),
        '126_body_health.txt': ('body_health', None),
        # School (127-133)
        '127_school.txt': ('education_knowledge', None),
        '128_school.txt': ('education_knowledge', None),
        '129_school.txt': ('education_knowledge', None),
        '130_school.txt': ('education_knowledge', None),
        '131_school.txt': ('education_knowledge', None),
        '132_school.txt': ('education_knowledge', None),
        '133_school.txt': ('education_knowledge', None),
        # Landmarks (134-141)
        '134_landmarks.txt': ('travel_tourism', None),
        '135_landmarks.txt': ('travel_tourism', None),
        '136_landmarks.txt': ('travel_tourism', None),
        '137_landmarks.txt': ('travel_tourism', None),
        '138_landmarks.txt': ('travel_tourism', None),
        '139_landmarks.txt': ('travel_tourism', None),
        '140_landmarks.txt': ('travel_tourism', None),
        '141_landmarks.txt': ('travel_tourism', None),
    }

    total_ok = 0
    total_fail = 0
    for fname, (cat, _) in prompt_map.items():
        ok, fail = process_prompt(fname, cat, None)
        total_ok += ok
        total_fail += fail

    print(f'\nTotal OK: {total_ok}, Failed: {total_fail}')

if __name__ == '__main__':
    main()