<template>
  <div id="designer">
    <div class="toolbar">
      <div class="toolbar-container">
        <div>
          <a-select
            class="d-inline-block"
            label="Template"
            dense
            attach
            v-model="currentTemplate"
            :items="templates"
            item-value="id"
            item-title="templateName"
            return-object
            @input="selectTemplate"
          >
          </a-select>
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
        <div>
          <v-tooltip bottom>
            <template #activator="{ on, attrs }">
              <a-btn
                v-bind="attrs"
                :activation-handler="on"
                @click="
                  ;[
                    (addBlock = !addBlock),
                    (tabs = addBlock ? 0 : tabs),
                    selectNode(undefined)
                  ]
                "
                variant="text"
                icon
                color="primary"
                :prepend-icon="addBlock ? 'close' : 'mdi-toy-brick-plus'"
              ></a-btn>
            </template>
            <span>Add Block</span>
          </v-tooltip>
        </div>
      </div>
      <div class="d-flex align-center">
        <a-btn
          icon
          variant="text"
          size="small"
          color="primary"
          class="mr-2"
          prepend-icon="mdi-pencil"
          @click="toggleObjectCategoryEdit(currentTemplate)"
        ></a-btn>
        <span
          v-if="!editObjectCategories"
          class="font-size-12 grey--text text--darken-1"
        >
          {{ getProposalHint(currentTemplate) }}
        </span>
        <div class="d-flex align-center justify-around flex-fill" v-else>
          <a-select
            attach
            v-model="editableItem.objectCategories"
            :items="objectCategories"
            label="Object Category"
            item-title="objectCategory"
            item-value="id"
            item-subtitle="kaleb"
            autocomplete="off"
            multiple
          >
            <template v-slot:item="{ active, item, attrs, on }">
              <v-list-item v-on="on" v-bind="attrs" #default="{ active }">
                <v-list-item-action>
                  <v-checkbox :input-value="active"></v-checkbox>
                </v-list-item-action>
                <v-list-item-content>
                  <v-list-item-title>
                    <v-row no-gutters align="center">
                      <span>{{ item.objectCategory }}</span>
                      <v-spacer></v-spacer>
                      <v-chip
                        v-if="item.templateId"
                        :color="
                          item?.templateId === currentTemplate?.id
                            ? 'primary'
                            : 'default'
                        "
                        small
                      >
                        {{ item.templateName }}
                      </v-chip>
                    </v-row>
                  </v-list-item-title>
                </v-list-item-content>
              </v-list-item>
            </template>
          </a-select>

          <a-btn
            variant="text"
            color="primary"
            class="ml-3"
            @click="toggleObjectCategoryEdit(currentTemplate)"
          >
            cancel
          </a-btn>
          <a-btn @click="saveObjectCategories(editableItem.objectCategories)">
            save
          </a-btn>
        </div>
      </div>
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
            <div v-if="addBlock">
              <AddComponentWidget
                :existing-blocks="template"
                @cancel="addBlock = false"
                @input="updateAddValue"
              ></AddComponentWidget>
            </div>
            <v-card v-else-if="selected">
              <div class="sticky-header">
                <v-card-title class="d-flex ml-n2">
                  <v-tooltip left>
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
                  <span v-if="!editBlockName">{{ selected?.displayName }}</span>
                  <a-text-field
                    v-else
                    type="string"
                    color="primary"
                    v-model="editedBlockName"
                    label="Block Name"
                  ></a-text-field>
                  <span v-if="selected.modified">*</span>
                  <v-spacer />
                  <v-tooltip left v-if="!editBlockName">
                    <template #activator="{ on, attrs }">
                      <a-btn
                        v-bind="attrs"
                        :activation-handler="on"
                        @click="editBlockName = true"
                        :disabled="!selected"
                        icon
                        variant="text"
                        prepend-icon="edit"
                      />
                    </template>
                    Edit Block Name
                  </v-tooltip>
                  <a-btn
                    v-if="editBlockName"
                    @click="updateName(editedBlockName)"
                    :disabled="!selected"
                    icon
                    variant="text"
                    prepend-icon="check"
                  />
                  <a-btn
                    v-if="editBlockName"
                    @click="editBlockName = false"
                    :disabled="!selected"
                    icon
                    variant="text"
                    prepend-icon="close"
                  />
                  <v-tooltip top v-if="!editBlockName">
                    <template #activator="{ on, attrs }">
                      <a-btn
                        v-bind="attrs"
                        :activation-handler="on"
                        @click="showDeleteDialog = true"
                        :disabled="!selected"
                        icon
                        variant="text"
                        prepend-icon="delete"
                      />
                    </template>
                    Delete Block
                  </v-tooltip>
                </v-card-title>
                <v-card-subtitle
                  v-if="parent"
                  class="px-6 pb-0 d-flex align-baseline"
                >
                  <span class="grey--text text--darken-1 label-small pr-1">
                    Parent:
                  </span>
                  <v-tooltip right>
                    <template #activator="{ on, attrs }">
                      <span
                        class="clickable primary--text d-flex"
                        @click="selectNode(parent.id)"
                        v-bind="attrs"
                        v-on="on"
                      >
                        {{ parent?.displayName }}
                      </span>
                    </template>
                    <span>Go to Parent</span>
                  </v-tooltip>
                </v-card-subtitle>
              </div>
              <div class="px-4">
                <v-card
                  v-if="selected && selected.blockType === 'PageBlock'"
                  flat
                  class="text-left px-3"
                  color="transparent"
                >
                  <v-card-title class="px-0 pt-0">Location</v-card-title>
                  <LocationSelectorWidget
                    attr="pageLocation"
                    :existing-blocks="pages"
                  />
                </v-card>
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

            <v-card flat v-else>
              <v-card-text>Please select a block to edit</v-card-text>
            </v-card>
          </v-tab-item>
          <v-tab-item>
            <div class="d-flex justify-space-between align-center px-4">
              <v-chip
                label
                outlined
                color="primary--text"
                class="mt-4 mb-0 sort-chip align-self-center albatross-body-2 flex-shrink-0"
                @click=";[(sortById = !sortById), (expandAll = true)]"
              >
                {{ sortById ? 'Sort by doc order' : 'Sort by Id' }}
              </v-chip>
              <a-btn
                variant="text"
                color="primary"
                @click="expandAll = !expandAll"
              >
                {{ expandAll ? 'Collapse All' : 'Expand All' }}
              </a-btn>
            </div>
            <v-card class="mx-auto pa-4" flat>
              <nested-tree
                :children="pages"
                :sort-by-id="sortById"
                :expandAll="expandAll"
                @select="focusNode"
                id="props-designer-tree"
              />
            </v-card>
          </v-tab-item>
        </v-tabs-items>
      </div>
    </div>
    <ConfirmationDialog
      :open-dialog="showDeleteDialog"
      @cancel="showDeleteDialog = false"
      @confirm="deleteBlock"
      @close-dialog="showDeleteDialog = false"
    >
      <span class="bold error-text">WARNING: This cannot be undone.</span>
      <div>
        Are you sure you want to delete this block:
        <b>{{ selected?.displayName }}</b>
        ? All children will also be deleted.
      </div>
    </ConfirmationDialog>
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
import AddComponentWidget from './panel/AddComponentWidget.vue'
import LocationSelectorWidget from './panel/LocationSelectorWidget.vue'

import ProposalTemplate from './ProposalTemplate'
import { apiRequest, getRequest, postRequest } from '@/helpers/helpers'
import { Editor } from '@tiptap/vue-2'
import { getExtensions } from '@/views/blueraven/settings/proposalDesigner/blocks/text/utils'

import { computed, ref, onMounted, watch, onBeforeUnmount, provide } from 'vue'
import { useAppStore } from '@/stores/AppStore.js'
import useProposalStore from './store.js'
import { storeToRefs } from 'pinia'

import ConfirmationDialog from '@/components/ConfirmationDialog.vue'

const appStore = useAppStore()
const store = useProposalStore()
const { selectedId, template, templates, currentTemplate } = storeToRefs(store)

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
  await Promise.allSettled([
    store.loadTemplates(),
    store.fetchTemplate(),
    getObjectCategories()
  ])
  await store.fetchTags()
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
const addBlock = ref(false)
const editBlockName = ref(false)
const editedBlockName = ref(null)
const showDeleteDialog = ref(false)
const activeEditor = ref(undefined)
const viewportEl = ref(null)
const sortById = ref(true)
const expandAll = ref(true)
const editObjectCategories = ref(false)
const objectCategories = ref([])

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

const selectTemplate = async (tmpl) => {
  await store.fetchTemplate(tmpl.id)
  await store.fetchTags()

  editObjectCategories.value = false
}

const editableItem = ref({})
const toggleObjectCategoryEdit = (editable) => {
  if (!editObjectCategories.value) {
    editableItem.value = structuredClone(editable)
  } else {
    editableItem.value = {}
  }
  editObjectCategories.value = !editObjectCategories.value
}

const saveObjectCategories = async (ids) => {
  const currentTemplateId = currentTemplate.value?.id

  await postRequest(
    `/proposal/template/${currentTemplateId}/objectCategories`,
    {
      objectCategoryIds: ids
    },
    'blueraven'
  )

  await getObjectCategories()
  currentTemplate.value.objectCategories = objectCategories?.value?.filter(
    (oc) => ids.includes(oc.id)
  )
  editableItem.value = {}
  editObjectCategories.value = false
}

const getObjectCategories = async () => {
  try {
    const { data } = await getRequest(
      `/proposal/template/objectCategories`,
      'blueraven'
    )
    objectCategories.value = data?.sort((a, b) =>
      a.objectCategory.localeCompare(b.objectCategory)
    )
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Object Categories')
  }
}

const getProposalHint = (item) => {
  if (!item?.objectCategories || item.objectCategories?.length < 1) {
    return 'No object categories selected'
  }
  return item.objectCategories
    .map((category) => {
      return category.objectCategory
    })
    .join(', ')
}

const updateValue = (value) => {
  store.setValue({
    blockId: selected.value.id,
    value
  })
}

const updateAddValue = ({ newBlock, blockLocation }) => {
  store.addBlock({ ...newBlock }, blockLocation)
  addBlock.value = false
}

const updateName = (name) => {
  store.setName({
    blockId: selected.value.id,
    name
  })
  editBlockName.value = false
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
    const currentTemplateId = currentTemplate.value?.id
    const { data } = await apiRequest('blueraven', {
      method: 'post',
      url: `/proposal-preview/${currentTemplateId}`,
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
const deleteBlock = async () => {
  appStore.loading = true
  await store.deleteSelectedBlock()
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
  editedBlockName.value = selected.value?.blockName
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

  & .toolbar-container {
    display: flex;
    justify-content: space-between;
  }
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
  height: calc(100vh - 250px);
}

.sticky-header {
  position: sticky;
  top: 0;
  background: white;
  z-index: 1;
}
</style>
