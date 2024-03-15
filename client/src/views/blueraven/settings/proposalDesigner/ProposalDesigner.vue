<template>
  <div id="designer">
    <div class="toolbar">
      <v-tooltip bottom>
        <template #activator="{on, attrs}">
          <AlbatrossButton
              v-bind="attrs"
              :activation-handler="on"
              @click="save"
              :disabled="!isSaveable"
              variant="text"
              icon
              color="unset"
              :prepend-icon="isSaveable ? 'cloud' : 'mdi-cloud-outline'"
          ></AlbatrossButton>
        </template>
        <span>Save</span>
      </v-tooltip>
      <v-tooltip bottom>
        <template #activator="{on, attrs}">
          <AlbatrossButton
              v-bind="attrs"
              :activation-handler="on"
              @click="undo"
              :disabled="!canUndo"
              variant="text"
              icon
              color="unset"
              prepend-icon="undo"
          ></AlbatrossButton>
        </template>
        <span>Undo</span>
      </v-tooltip>
      <v-tooltip bottom>
        <template #activator="{on, attrs}">
          <AlbatrossButton
              v-bind="attrs"
              :activation-handler="on"
              @click="redo"
              :disabled="!canRedo"
              variant="text"
              icon
              color="unset"
              prepend-icon="redo"
          ></AlbatrossButton>
        </template>
        <span>Redo</span>
      </v-tooltip>
      <v-tooltip bottom>
        <template #activator="{on, attrs}">
          <AlbatrossButton
              v-bind="attrs"
              :activation-handler="on"
              @click="reset"
              :disabled="!(canRedo || canUndo)"
              icon
              variant="text"
              color="unset"
              prepend-icon="mdi-nuke"
          ></AlbatrossButton>
        </template>
        <span>Reset</span>
      </v-tooltip>
      <v-tooltip bottom>
        <template #activator="{on, attrs}">
          <AlbatrossButton
              v-bind="attrs"
              :activation-handler="on"
              @click="downloadPreview"
              :disabled="isSaveable"
              icon
              variant="text"
              color="unset"
              prepend-icon="mdi-file-pdf-box"
          ></AlbatrossButton>
        </template>
        <span>Generate PDF Preview</span>
      </v-tooltip>
    </div>

    <div class="proposal-designer">
      <div class="main-content">
        <text-menu-widget class="text-menu" v-if="activeEditor" :editor="activeEditor"/>
        <viewport class="main-viewport" ref="viewport">
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
              <!--              TODO: themes and more styles + drag and drop -->
              <div class="sticky-header">
                <v-card-title>
                  <v-tooltip>
                    <template #activator="{on, attrs}">
                      <AlbatrossButton
                          v-bind="attrs"
                          :activation-handler="on"
                          @click="focusViewport"
                          :disabled="!selected"
                          icon
                          variant="text"
                          color="unset"
                          prepend-icon="mdi-image-filter-center-focus-weak"
                      ></AlbatrossButton>
                    </template>
                    <span>Focus</span>
                  </v-tooltip>
                  {{ selected.blockType }}
                  <span v-if="selected.modified">*</span>
                </v-card-title>
                <v-card-subtitle class="clickable"
                                 v-if="parent"
                                 @click="selectNode(parent.id)">^ {{ parent.blockType }}
                </v-card-subtitle>
              </div>
              <div class="pa-4">
                <!--                  <add-component-panel @input="addComponent" />-->

                <!--      TODO: add themeClass-->
                <!--      TODO: need to be able to edit theme -->
                <image-panel v-if="selected && selected.blockType === 'ImageBlock'" @input="updateValue"/>

                <style-panel
                  :type="selected.blockType"
                  :cssStyle="selected.blockStyle"
                  v-if="selected"
                  @input="updateStyles"/>

                <advanced-panel
                  :visibility="selected.visibility"
                  @input="updateVisibility"/>
              </div>
            </v-card>
          </v-tab-item>
          <v-tab-item>
            <v-card class="mx-auto pa-4" flat>
              <nested-tree :children="pages" @select="focusNode"/>
            </v-card>
          </v-tab-item>
        </v-tabs-items>
      </div>
    </div>
  </div>
</template>
<script setup>
import './styles/proposals.scss'
import {mapState} from 'vuex'
import Viewport from './viewport/Viewport'
import StylePanel from './panel/Style'
import ImagePanel from './panel/Image'
import NestedTree from './panel/NestedTree'
import AddComponentPanel from './panel/AddComponentWidget'
import TextMenuWidget from './panel/TextMenuWidget'
import AdvancedPanel from './panel/Advanced.vue'
import ProposalTemplate from './ProposalTemplate'
import {ProposalActions, ProposalMutations} from './store'
import {apiRequest} from '@/helpers/helpers'
import {AppMutations} from '@/stores/AppStore'
import {VuexUndoRedoMixin} from './mixin/VuexUndoRedoMixin'
import {Editor} from "@tiptap/vue-2";
import {getExtensions} from "@/views/blueraven/settings/proposalDesigner/blocks/text/utils";
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue"
import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStorePinia.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

function fixContainer(revert = false) {
  document.querySelectorAll('.router-container').forEach((node) => {
    node.style.overflow = revert ? '' : 'hidden'
  })

  document.querySelectorAll('.main-section').forEach(node => {
    node.style.overflow = revert ? '' : 'hidden'
  })
}

const StyleFixerMixin = {
  created() {
    fixContainer()
  },
  destroyed() {
    fixContainer(true)
  }
}

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

//@kaleb i dont know how to add your mixins
// mixins: [StyleFixerMixin, VuexUndoRedoMixin],

//@kaleb or this provide stuff
// provide() {
//   const editor = {}
//   Object.defineProperty(editor, 'current', {
//     enumerable: true,
//     get: () => this.activeEditor
//   })
//   return {
//     editor
//   }
// },

onMounted(() => {
  store.dispatch(ProposalActions.FETCH_TAGS)
  store.dispatch(ProposalActions.FETCH_TEMPLATE)
})

const tabs = ref(null)
const debug = ref(false)
const editable = ref(true)
const dragging = ref(false)
const activeEditor = ref(undefined)
const viewport = ref(null)

const { selectedId, template, tags } = mapState({
  selectedId: (state) => state.proposal.selectedId,
  template: (state) => state.proposal.template,
  tags: (state) => state.proposal.tags?.map(t => t.tagName)
})

watch(selectedId, async() => {
  const block = selected.value
  if (activeEditor.value) {
    activeEditor.value.destroy()
    activeEditor.value = undefined
  }

  if (!block || block.blockType !== 'TextBlock') {
    return
  }

  const self = this
  const content = block.blockValue ?? defaultDocument
  activeEditor.value = new Editor({
    content,
    autofocus: true,
    extensions: getExtensions({tags: tags.value}),
    onUpdate({editor}) {
      const payload = editor.getJSON()
      self.updateValue(payload)
    },
  })
})

    const selected = computed(() => {
      return store.getters.selectedBlock
    })
    const parent = computed(() => {
      return store.getters.findById(selected.value.parentId)
    })
    const pages = computed(() => {
      return template.value?.filter(x => x.parentId === undefined)
    })
    const isSaveable = computed(() => {
      return store.getters.modifiedBlocks?.length > 0
    })
    const isFullAdmin = computed(() => {
      return userStore.isSystemAdmin
    })



    const addComponent = ({blockType, blockTypeId, blockValue}) => {
      store.commit(ProposalMutations.ADD_COMPONENT, {
        parentId: selected.value.id,
        blockType,
        blockTypeId,
        blockValue,
        order: 1
      })
    }
    const updateValue = (value) => {
      store.commit(ProposalMutations.SET_VALUE, {blockId: selected.value.id, value})
    }
    const updateStyles = (styles) => {
      store.commit(ProposalMutations.SET_STYLE, {blockId: selected.value.id, styles})
    }
    const updateVisibility = (visibility) => {
      store.commit(ProposalMutations.SET_VISIBILITY, {blockId: selected.value.id, visibility})
    }
    const downloadPreview = async() => {
      try {

        appStore.loading = true
        const {data} = await apiRequest('blueraven', {
          method: 'post',
          url: '/proposal-preview/1',
          responseType: 'blob'
        })

        if (data) {
          const pdfFile = URL.createObjectURL(new Blob([data], {type: 'application/pdf'}))
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
        snackbar('ERROR', e?.data?.message || 'Error while generating preview')
        console.error(e)
      } finally {
        appStore.loading = false
      }
    }
    const save = async() => {
      appStore.loading = true
      await store.dispatch(ProposalActions.SAVE_TEMPLATE)
      reset()
      appStore.loading = false
    }
    const selectNode = (id) => {
      store.commit(ProposalMutations.SET_SELECTED, id)
      // this.focusNode(id)
    }
    const focusViewport = () => {
      if (!selected.value) {
        return
      }

      focusNode(selected.value.id)
    }
    const focusNode = (id) => {
      const vp = viewport.value.$el
      const nodes = vp.querySelectorAll(`[data-id="${id}"]`)
      if (nodes.length > 0) {
        const rect = nodes[0].getBoundingClientRect()
        const top = vp.scrollTop + rect.top - 220
        vp.scrollTo({top, behavior: 'smooth'})
      }
    }
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
