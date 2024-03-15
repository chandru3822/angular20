<template>
  <div class="proposal-text" :style="styles">
    <fragment v-if="!editable || editable && (selectedId !== id)" v-html="html" v-bind="$attrs"/>
    <fragment v-else>
      <text-editor v-if="editor.current" :editor="editor.current"/>
    </fragment>
  </div>
</template>
<script setup>
import TextEditor from './text/TextEditor'
import {generateHTMLFromJSON} from './text/utils'
import {mapState} from 'vuex'
import {Fragment} from 'vue-frag'
import {getCurrentInstance, toRefs, computed, ref, onMounted, watch} from 'vue'

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

const html = ref('')

//@kaleb how to?
// inject: ['editor'],

//@kaleb not sure if these map state things are right
const {selectedId, theme} = mapState({
  selectedId: state => state.proposal.selectedId,
  theme: (state) => state.proposal.theme
})
const styles = computed(() => {
  const themeStyles = theme.value[props.themeKey] ?? {}
  return {...themeStyles, ...props.blockStyle}
})

watch(props.blockValue, (newVal) => {
  html.value = generateHtml(newVal);
}, {immediate: true});

const generateHtml = (val) => {
  try {
    //trick the fragment into always updating
    const commentEl = document.createComment(`fragment#id=${props.id} last_updated=${new Date().valueOf()}`)
    const serializeToString = xmlSerializer.serializeToString(commentEl)
    const htmlFromJSON = generateHTMLFromJSON(val)

    return serializeToString + htmlFromJSON
  } catch (e) {
    console.error('ID:', props.id, e)
  }
  return ''
}
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
