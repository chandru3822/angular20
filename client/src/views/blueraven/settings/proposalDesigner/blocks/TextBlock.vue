<template>
  <div class="proposal-text" :style="styles">
    <fragment
      v-if="!editable || (editable && selectedId !== id)"
      v-html="html"
      v-bind="$attrs"
    />
    <fragment v-else>
      <text-editor v-if="editor.current" :editor="editor.current" />
    </fragment>
  </div>
</template>
<script setup>
import { Fragment } from 'vue-frag'
import { computed, inject, ref, toRefs, watch } from 'vue'
import { storeToRefs } from 'pinia'
import useProposalStore from '../store.js'
import TextEditor from './text/TextEditor'
import { generateHTMLFromJSON } from './text/utils'

const store = useProposalStore()
const { theme, selectedId } = storeToRefs(store)

const xmlSerializer = new XMLSerializer()

const props = defineProps({
  id: {
    required: true
  },
  blockValue: {
    type: Object,
    required: true
  },
  themeKey: {
    type: String
  },
  editable: {
    type: Boolean
  },
  blockStyle: {
    type: Object,
    default: function () {
      return {}
    }
  }
})

const { blockValue } = toRefs(props)

const html = ref('')
const editor = inject('editor')

const styles = computed(() => {
  const themeStyles = theme.value[props.themeKey] ?? {}
  return { ...themeStyles, ...props.blockStyle }
})

const generateHtml = (val) => {
  try {
    //trick the fragment into always updating
    const commentEl = document.createComment(
      `fragment#id=${props.id} last_updated=${new Date().valueOf()}`
    )
    const serializeToString = xmlSerializer.serializeToString(commentEl)
    const htmlFromJSON = generateHTMLFromJSON(val)

    return serializeToString + htmlFromJSON
  } catch (e) {
    console.error('ID:', props.id, e)
  }
  return ''
}

watch(
  blockValue,
  (newVal) => {
    html.value = generateHtml(newVal)
  },
  { immediate: true }
)
</script>

<style lang="scss">
.proposal-text {
  table {
    border-collapse: collapse;
    table-layout: fixed;
    width: 100%;
    margin: 0;
    overflow: hidden;

    td,
    th {
      min-width: 1em;
      padding: 3px 5px;
      vertical-align: top;
      box-sizing: border-box;
      position: relative;

      > * {
        margin-bottom: 0;
      }
    }

    th {
      font-weight: bold;
      text-align: left;
    }

    p {
      margin: 0;
    }
  }

  p {
    margin: 0;
  }
}
</style>
