<template>
  <div id="designer">
    <div class="toolbar">
      <v-tooltip bottom>
        <template #activator="{ on, attrs }">
          <a-btn
            v-bind="attrs"
            :activation-handler="on"
            @click="save"
            :disabled="!isSaveable"
            variant="text"
            icon
            color="unset"
            :prepend-icon="isSaveable ? 'cloud' : 'mdi-cloud-outline'"
          ></a-btn>
        </template>
        <span>Save</span>
      </v-tooltip>
      <v-tooltip bottom>
        <template #activator="{ on, attrs }">
          <a-btn
            v-bind="attrs"
            :activation-handler="on"
            @click="store.undo"
            :disabled="!store.canUndo"
            variant="text"
            icon
            color="unset"
            prepend-icon="undo"
          ></a-btn>
        </template>
        <span>Undo</span>
      </v-tooltip>
      <v-tooltip bottom>
        <template #activator="{ on, attrs }">
          <a-btn
            v-bind="attrs"
            :activation-handler="on"
            @click="store.redo"
            :disabled="!store.canRedo"
            variant="text"
            icon
            color="unset"
            prepend-icon="redo"
          ></a-btn>
        </template>
        <span>Redo</span>
      </v-tooltip>
      <v-tooltip bottom>
        <template #activator="{ on, attrs }">
          <a-btn
            v-bind="attrs"
            :activation-handler="on"
            @click="store.reset"
            :disabled="!(store.canRedo || store.canUndo)"
            icon
            variant="text"
            color="unset"
            prepend-icon="mdi-nuke"
          ></a-btn>
        </template>
        <span>Reset</span>
      </v-tooltip>
      <v-tooltip bottom>
        <template #activator="{ on, attrs }">
          <a-btn
            v-bind="attrs"
            :activation-handler="on"
            @click="downloadPreview"
            :disabled="isSaveable"
            icon
            variant="text"
            color="unset"
            prepend-icon="mdi-file-pdf-box"
          ></a-btn>
        </template>
        <span>Generate PDF Preview</span>
      </v-tooltip>
    </div>

    <div class="proposal-designer">
      <div class="main-content">
        <text-menu-widget
          class="text-menu"
          v-if="activeEditor"
          :editor="activeEditor"
        />
        <viewport class="main-viewport" ref="viewportEl">
          <proposal-template
            v-if="pages && pages.length > 0"
            :children="pages"
            :debug="debug"
            :editable="editable"
          />
        </viewport>
      </div>
      <div class="main-sidebar">
        <v-tabs v-model="tabs">
          <v-tab>Editor</v-tab>
          <v-tab>Tree</v-tab>
        </v-tabs>
        <v-tabs-items v-model="tabs" class="tabs-scrollable">
          <v-tab-item>
            <v-card v-if="selected">
              <div class="sticky-header">
                <v-card-title>
                  <v-tooltip>
                    <template #activator="{ on, attrs }">
                      <a-btn
                        v-bind="attrs"
                        :activation-handler="on"
                        @click="focusViewport"
                        :disabled="!selected"
                        icon
                        variant="text"
                        color="unset"
                        prepend-icon="mdi-image-filter-center-focus-weak"
                      ></a-btn>
                    </template>
                    <span>Focus</span>
                  </v-tooltip>
                  {{ selected.blockType }}
                  <span v-if="selected.modified">*</span>
                </v-card-title>
                <v-card-subtitle
                  class="clickable"
                  v-if="parent"
                  @click="selectNode(parent.id)"
                  >^ {{ parent.blockType }}
                </v-card-subtitle>
              </div>
              <div class="pa-4">
                <image-panel
                  v-if="selected && selected.blockType === 'ImageBlock'"
                  @input="updateValue"
                />

                <style-panel
                  :type="selected.blockType"
                  :cssStyle="selected.blockStyle"
                  v-if="selected"
                  @input="updateStyles"
                />

                <advanced-panel
                  :visibility="selected.visibility"
                  @input="updateVisibility"
                />
              </div>
            </v-card>
          </v-tab-item>
          <v-tab-item>
            <v-card class="mx-auto pa-4" flat>
              <nested-tree :children="pages" @select="focusNode" />
            </v-card>
          </v-tab-item>
        </v-tabs-items>
      </div>
    </div>
  </div>
</template>
<script setup>
import './styles/proposals.scss'
import Viewport from './viewport/Viewport'
import StylePanel from './panel/Style'
import ImagePanel from './panel/Image'
import NestedTree from './panel/NestedTree'
import TextMenuWidget from './panel/TextMenuWidget'
import AdvancedPanel from './panel/Advanced.vue'
import ProposalTemplate from './ProposalTemplate'
import { apiRequest } from '@/helpers/helpers'
import { Editor } from '@tiptap/vue-2'
import { getExtensions } from '@/views/blueraven/settings/proposalDesigner/blocks/text/utils'

import { computed, ref, onMounted, watch, onBeforeUnmount, provide } from 'vue'
import { useAppStore } from '@/stores/AppStore.js'
import useProposalStore from './store.js'
import { storeToRefs } from 'pinia'

const appStore = useAppStore()

const store = useProposalStore()
const { selectedId, template } = storeToRefs(store)

const historyKeyListener = function (e) {
  if (e.key === 'z' && (e.ctrlKey || e.metaKey)) {
    e.preventDefault()
    if (store.canUndo) {
      store.undo()
    }
  }

  if (e.keyCode === 'Z' && e.shiftKey && (e.ctrlKey || e.metaKey)) {
    e.preventDefault()
    if (store.canRedo) {
      store.redo()
    }
  }
}

onMounted(async () => {
  document.addEventListener('keydown', historyKeyListener)
  await Promise.allSettled([store.fetchTags(), store.fetchTemplate()])
})

onBeforeUnmount(() =>
  document.removeEventListener('keydown', historyKeyListener)
)

const defaultDocument = {
  type: 'doc',
  content: [
    {
      type: 'paragraph',
      content: [
        {
          type: 'text',
          text: ''
        }
      ]
    }
  ]
}

const tabs = ref(null)
const debug = ref(false)
const editable = ref(true)
const activeEditor = ref(undefined)
const viewportEl = ref(null)

const editor = {}
Object.defineProperty(editor, 'current', {
  enumerable: true,
  get: () => activeEditor
})

provide('editor', editor)

const selected = computed(() => store.selectedBlock)
const parent = computed(() => store.findById(store.selectedBlock?.parentId))
const pages = computed(() =>
  template.value?.filter((x) => x.parentId === undefined)
)
const isSaveable = computed(() => store.modifiedBlocks?.length > 0)
const tags = computed(() => store.tags?.map((t) => t.tagName))

const updateValue = (value) => {
  store.setValue({
    blockId: selected.value.id,
    value
  })
}
const updateStyles = (styles) => {
  store.setStyle({
    blockId: selected.value.id,
    styles
  })
}
const updateVisibility = (visibility) => {
  store.setVisibility({
    blockId: selected.value.id,
    visibility
  })
}
const downloadPreview = async () => {
  try {
    appStore.loading = true
    const { data } = await apiRequest('blueraven', {
      method: 'post',
      url: '/proposal-preview/1',
      responseType: 'blob'
    })

    if (data) {
      const pdfFile = URL.createObjectURL(
        new Blob([data], { type: 'application/pdf' })
      )
      const docUrl = document.createElement('a')
      docUrl.href = pdfFile
      docUrl.setAttribute('download', 'preview.pdf')
      document.body.appendChild(docUrl)
      docUrl.click()
      setTimeout(() => {
        docUrl.remove()
        URL.revokeObjectURL(pdfFile)
      }, 100)
    }
  } catch (e) {
    appStore.showSnack(
      'ERROR',
      e?.data?.message || 'Error while generating preview'
    )
    console.error(e)
  } finally {
    appStore.loading = false
  }
}
const save = async () => {
  appStore.loading = true
  await store.saveTemplate()
  appStore.loading = false
}

const selectNode = (id) => {
  store.setSelected(id)
}

const focusViewport = () => {
  if (!selected.value) {
    return
  }

  focusNode(selected.value.id)
}
const focusNode = (id) => {
  const vp = viewportEl.value.$el
  const nodes = vp.querySelectorAll(`[data-id="${id}"]`)
  if (nodes.length > 0) {
    const rect = nodes[0].getBoundingClientRect()
    const top = vp.scrollTop + rect.top - 220
    vp.scrollTo({ top, behavior: 'smooth' })
  }
}

watch(selectedId, async () => {
  const block = selected.value
  if (activeEditor.value) {
    activeEditor.value.destroy()
    activeEditor.value = undefined
  }

  if (!block || block.blockType !== 'TextBlock') {
    return
  }

  const content = block.blockValue ?? defaultDocument
  activeEditor.value = new Editor({
    content,
    autofocus: true,
    extensions: getExtensions({ tags: tags.value }),
    onUpdate({ editor }) {
      const payload = editor.getJSON()
      updateValue(payload)
    }
  })
})
</script>
<style lang="scss" scoped>
#designer {
  margin: 0;
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.toolbar {
  position: sticky;
  top: 0;
  z-index: 100;
  background-color: white;
  padding: 10px;
}

.proposal-designer {
  background-color: white;
  display: grid;
  grid-template-columns: minmax(0, 2fr) 1fr;
  grid-template-rows: 1fr;
  grid-column-gap: 0;
  grid-row-gap: 0;
  height: calc(100vh - 120px);

  & p {
    margin: 0 !important;
    padding: 0 !important;
  }
}

.main-content {
  grid-area: 1 / 1 / 2 / 2;
}

.main-sidebar {
  grid-area: 1 / 2 / 2 / 3;
}

.tabs-scrollable {
  overflow: auto;
  height: calc(100vh - 165px);
}

.sticky-header {
  position: sticky;
  top: 0;
  background: white;
  z-index: 1;
}
</style>
