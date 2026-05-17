import { defineComponent, h } from 'vue'
import AppIcon from '@/components/AppIcon.vue'

function icon(name: string) {
  return defineComponent({
    props: {
      size:  { type: [String, Number], default: 24 },
      color: { type: String, default: '#000000' },
    },
    setup(props) {
      return () => h(AppIcon, { name, size: props.size, color: props.color })
    },
  })
}

export const IconHome          = icon('home')
export const IconTimeline      = icon('timeline')
export const IconCamera        = icon('camera')
export const IconMap           = icon('map')
export const IconCollection    = icon('heart')
export const IconProfile       = icon('user')
export const IconUser          = icon('user')
export const IconEdit          = icon('edit')
export const IconDelete        = icon('trash')
export const IconFavorite      = icon('heart')
export const IconShare         = icon('share')
export const IconMore          = icon('more')
export const IconBack          = icon('back')
export const IconPlus          = icon('plus')
export const IconCheck         = icon('check')
export const IconX             = icon('x')
export const IconClock         = icon('clock')
export const IconLocation      = icon('location')
export const IconMapPin        = icon('location')
export const IconImage         = icon('image')
export const IconStampClassic  = icon('stampClassic')
export const IconStampNature   = icon('stampNature')
export const IconStampCity     = icon('stampCity')
export const IconGlobe         = icon('globe')
export const IconBookOpen      = icon('bookOpen')
export const IconRocket        = icon('rocket')
export const IconCheckCircle   = icon('checkCircle')
export const IconClipboardList = icon('clipboardText')
export const IconAirplane      = icon('airplane')
export const IconCrown         = icon('crown')
export const IconEnvelope      = icon('envelope')
export const IconArticle       = icon('article')
export const IconStampCulture  = icon('stampCulture')
export const IconStampSea      = icon('stampSea')
export const IconStampSunset   = icon('stampSunset')
export const IconMailbox       = icon('mailbox')
export const IconInfo          = icon('info')
export const IconReset         = icon('reset')
export const IconShield        = icon('shield')
export const IconFileText      = icon('fileText')
export const IconSettings      = icon('gear')
export const IconSignOut       = icon('signOut')
export const IconCaretRight    = icon('caretRight')
export const IconSend          = icon('send')
export const IconInbox         = icon('inbox')
export const IconSearch        = icon('search')
export const IconShop          = icon('shop')
export const IconStar          = icon('star')
export const IconLock          = icon('lock')
export const IconEye           = icon('eye')
export const IconEyeSlash      = icon('eyeSlash')
export const IconContacts      = icon('contacts')
