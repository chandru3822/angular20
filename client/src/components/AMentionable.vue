<!-- This is just the 'vue-mention' component that chat gpt converted to composition API
     and uses v-menu instead of VPopover and floating-vue. Additionally it can use multi character
     keys as the trigger for the mention. #Thank you chatGPT -->

<template>
  <div
    ref="el"
    class="mentionable"
    :class="$attrs.class"
    style="position: relative"
  >
    <slot />
    <v-menu
      v-model="menuOpen"
      :close-on-content-click="false"
      :activator="el"
      offset-y
      :max-height="props.height"
      :max-width="props.width"
    >
      <template v-slot:default="menu">
        <v-list v-if="displayedItems.length">
          <v-list-item
            v-for="(item, index) in displayedItems"
            :key="index"
            @click="applyMention(index)"
            @mouseover="selectedIndex = index"
            @mousedown="applyMention(index + 1)"
          >
            <v-list-item-title>{{
              item.label || item.value
            }}</v-list-item-title>
          </v-list-item>
        </v-list>
      </template>
    </v-menu>
  </div>
</template>

<script setup>
import {
  computed,
  onMounted,
  onUnmounted,
  onUpdated,
  ref,
  watch,
  nextTick
} from 'vue'
import { defineProps, defineEmits } from 'vue'

const props = defineProps({
  keys: {
    type: Array,
    required: true
  },
  items: {
    type: Array,
    default: () => []
  },
  omitKey: {
    type: Boolean,
    default: false
  },
  filteringDisabled: {
    type: Boolean,
    default: false
  },
  insertSpace: {
    type: Boolean,
    default: false
  },
  mapInsert: {
    type: Function,
    default: null
  },
  limit: {
    type: String,
    default: '8'
  },
  clearOnBackspace: {
    type: Boolean,
    default: false
  },
  width: {
    type: String,
    default: '300'
  },
  height: {
    type: String,
    default: '300'
  }
})

const emit = defineEmits(['search', 'open', 'close', 'apply', 'clear'])
const currentKey = ref(null)
let currentKeyIndex = 0
const oldKey = ref(null)
const searchText = ref(null)
const selectedIndex = ref(0)
let input = null
const el = ref(null)
const menuOpen = ref(false)
const isUserInput = ref(false)

const filteredItems = computed(() => {
  if (!searchText.value || props.filteringDisabled) {
    return props.items
  }
  const finalSearchText = searchText.value.trim().toLowerCase()
  return props.items.filter((item) => {
    let text = item.searchText || item.label || ''
    for (const key in item) {
      if (!item.searchText && !item.label) {
        text += item[key]
      }
    }
    return text.toLowerCase().includes(finalSearchText)
  })
})

const displayedItems = computed(() =>
  filteredItems.value.slice(0, parseInt(props.limit))
)

watch(searchText, (value, oldValue) => {
  emit('search', value, oldValue)
})

watch(
  displayedItems,
  (newItems) => {
    selectedIndex.value = 0
    if (searchText.value) {
      const match = newItems.find(
        (item) =>
          item?.label?.toLowerCase() ===
            searchText.value.trim().toLowerCase() ||
          item?.value?.toLowerCase() === searchText.value.trim().toLowerCase()
      )
      if (match) {
        applyMention(newItems.indexOf(match) + 1)
      }
    }
  },
  { deep: true }
)

const getInput = () =>
  el.value.querySelector('input') ||
  el.value.querySelector('textarea') ||
  el.value.querySelector('[contenteditable="true"]')

onMounted(() => {
  input = getInput()
  attach()
})

onUpdated(() => {
  const newInput = getInput()
  if (newInput !== input) {
    detach()
    input = newInput
    attach()
  }
})

onUnmounted(() => {
  detach()
})

const attach = () => {
  if (input) {
    input.addEventListener('input', onInput)
    input.addEventListener('keydown', onKeyDown)
    input.addEventListener('focus', onFocus)
    input.addEventListener('blur', onBlur)
  }
}

const detach = () => {
  if (input) {
    input.removeEventListener('input', onInput)
    input.removeEventListener('keydown', onKeyDown)
    input.removeEventListener('focus', onFocus)
    input.removeEventListener('blur', onBlur)
  }
}

const onInput = () => {
  isUserInput.value = true
  checkKey()
}

const onFocus = () => {
  isUserInput.value = false
}

const onBlur = () => {
  closeMenu()
}

const onKeyDown = (e) => {
  //the following stops the menu from opening when you're trying to scroll through multi-line text
  if (!currentKey.value && (e.key === 'ArrowDown' || e.key === 'ArrowUp')) {
    e.stopImmediatePropagation()
  }
  if (currentKey.value) {
    if (e.key === 'ArrowDown') {
      selectedIndex.value =
        (selectedIndex.value + 1) % displayedItems.value.length
      e.preventDefault()
    } else if (e.key === 'ArrowUp') {
      selectedIndex.value =
        (selectedIndex.value - 1 + displayedItems.value.length) %
        displayedItems.value.length
      e.preventDefault()
    } else if (e.key === 'Enter' || e.key === 'Tab') {
      applyMention(selectedIndex.value)
      e.preventDefault()
    } else if (e.key === 'Escape') {
      closeMenu()
      e.preventDefault()
    }
  }
  if ((e.metaKey || e.ctrlKey) && e.key === 'Backspace') {
    closeMenu()
    emit('clear')
  }
  if (e.key === 'Backspace' && oldKey.value) {
    if (searchText.value === null || searchText.value === '') {
      emit('clear')
    }
    if (oldKey.value && props.clearOnBackspace === true) {
      setValue('')
      setCaretPosition(0)
      emit('clear')
      e.preventDefault()
      oldKey.value = ''
    }
  }
}

const getSelectionStart = () => {
  return input.isContentEditable
    ? window.getSelection().anchorOffset
    : input.selectionStart
}

const setCaretPosition = (index) => {
  nextTick(() => {
    input.selectionEnd = index
  })
}

const getValue = () => {
  return input.isContentEditable
    ? window.getSelection().anchorNode.textContent
    : input.value
}

const setValue = (value) => {
  input.value = value
  input.dispatchEvent(new Event('input'))
}

const checkKey = () => {
  if (!isUserInput.value) return

  const index = getSelectionStart()
  if (index >= 0) {
    const { key, keyIndex } = getLastKeyBeforeCaret(index)
    const text = getLastSearchText(index, keyIndex, key)
    // if (!(keyIndex < 1 || /(\s)/.test(getValue()[keyIndex - 1]))) {
    //   return false
    // }
    if (text != null) {
      openMenu(key, keyIndex)
      searchText.value = text.trim()
      return true
    }
  }
  if (searchText.value === null) {
    currentKey.value = null
  }
  closeMenu()
  return false
}

const getLastKeyBeforeCaret = (caretIndex) => {
  const [keyData] = props.keys
    .map((key) => ({
      key,
      keyIndex: getValue()
        .toLowerCase()
        .lastIndexOf(key.toLowerCase(), caretIndex - 1)
    }))
    .sort((a, b) => b.keyIndex - a.keyIndex)
  return keyData
}

const getLastSearchText = (caretIndex, keyIndex, key) => {
  if (keyIndex !== -1) {
    const text = getValue().substring(keyIndex + key.length, caretIndex)
    if (!/((\s)(?:.*)){4,}/.test(text)) {
      return text
    }
  }
  return null
}

const openMenu = (key, keyIndex) => {
  if (currentKey.value !== key) {
    currentKey.value = key
    currentKeyIndex = keyIndex
    selectedIndex.value = 0
    menuOpen.value = true
    emit('open', currentKey.value)
  }
}

const closeMenu = () => {
  if (currentKey.value != null) {
    oldKey.value = currentKey.value
    currentKey.value = null
    menuOpen.value = false
    emit('close', oldKey.value)
  }
}

const applyMention = (itemIndex) => {
  if (itemIndex === 0) {
    itemIndex = 1
  }
  const item = displayedItems.value[itemIndex - 1]
  const value =
    (props.omitKey ? '' : currentKey.value) +
    String(
      props.mapInsert ? props.mapInsert(item, currentKey.value) : item.value
    ) +
    (props.insertSpace ? ' ' : '')
  if (input.isContentEditable) {
    const range = window.getSelection().getRangeAt(0)
    range.setStart(
      range.startContainer,
      range.startOffset -
        currentKey.value.length -
        (searchText.value ? searchText.value.length : 0)
    )
    range.deleteContents()
    range.insertNode(document.createTextNode(value))
    range.setStart(range.endContainer, range.endOffset)
    input.dispatchEvent(new Event('input'))
  } else {
    setValue(
      replaceText(
        getValue(),
        searchText.value,
        value,
        currentKeyIndex,
        currentKey.value
      )
    )
    setCaretPosition(currentKeyIndex + value.length + 1)
  }

  emit('apply', item, currentKey.value, value, false)
  closeMenu()
}

const replaceText = (text, searchString, newText, index, key) => {
  return (
    text.slice(0, index) +
    newText +
    text.slice(index + searchString.length + key.length + 1, text.length)
  )
}
</script>

<style scoped>
#mentioned-list v-list-item--highlighted {
  background-color: white;
}
</style>
