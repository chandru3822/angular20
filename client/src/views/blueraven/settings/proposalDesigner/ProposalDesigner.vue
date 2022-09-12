<template>
  <div id="designer">
    <!--    <div class="dpi"></div>-->
    <div class="toolbar">
      <v-tooltip bottom>
        <template #activator="{on, attrs}">
          <v-btn v-bind="attrs" v-on="on" @click="save" :disabled="!isSaveable" text icon>
            <v-icon v-if="isSaveable">cloud</v-icon>
            <v-icon v-else>mdi-cloud-outline</v-icon>
          </v-btn>
        </template>
        <span>Save</span>
      </v-tooltip>
      <v-tooltip bottom>
        <template #activator="{on, attrs}">
          <v-btn v-bind="attrs" v-on="on" @click="undo" :disabled="!canUndo" text icon>
            <v-icon>undo</v-icon>
          </v-btn>
        </template>
        <span>Undo</span>
      </v-tooltip>
      <v-tooltip bottom>
        <template #activator="{on, attrs}">
          <v-btn v-bind="attrs" v-on="on" @click="redo" :disabled="!canRedo" text icon>
            <v-icon>redo</v-icon>
          </v-btn>
        </template>
        <span>Redo</span>
      </v-tooltip>
      <v-tooltip bottom>
        <template #activator="{on, attrs}">
          <v-btn v-bind="attrs" v-on="on" @click="reset" :disabled="!(canRedo || canUndo)" icon text>
            <v-icon>mdi-nuke</v-icon>
          </v-btn>
        </template>
        <span>Reset</span>
      </v-tooltip>
      <v-tooltip bottom>
        <template #activator="{on, attrs}">
          <v-btn v-bind="attrs" v-on="on" @click="downloadPreview" :disabled="isSaveable" icon text>
            <v-icon>mdi-file-pdf-box</v-icon>
          </v-btn>
        </template>
        <span>Generate PDF Preview</span>
      </v-tooltip>
    </div>

    <div class="proposal-designer">
      <div class="main-content">
        <text-menu-widget class="text-menu" v-if="activeEditor" :editor="activeEditor" />
        <viewport class="main-viewport" ref="viewport">
          <proposal-template v-if="pages && pages.length > 0" :children="pages" :debug="debug" :editable="editable" />
        </viewport>
      </div>
      <div class="main-sidebar">
        <v-tabs v-model="tabs">
          <v-tab>Editor</v-tab>
          <v-tab>Tree</v-tab>
        </v-tabs>
        <v-tabs-items v-model="tabs">
          <v-tab-item>
            <v-card v-if="selected">

              <!--              TODO: themes and more styles + drag and drop -->
              <v-card-title>
                <v-tooltip>
                  <template #activator="{on, attrs}">
                    <v-btn v-bind="attrs" v-on="on" @click="focusViewport" :disabled="!selected" icon text>
                      <v-icon>mdi-image-filter-center-focus-weak</v-icon>
                    </v-btn>
                  </template>
                  <span>Focus</span>
                </v-tooltip>
                {{ selected.blockType }}
              </v-card-title>
              <v-card-subtitle class="clickable"
                               v-if="parent"
                               @click="selectNode(parent.id)">^ {{ parent.blockType }}
              </v-card-subtitle>

              <div class="pa-4">
                <!--                  <add-component-panel @input="addComponent" />-->

                <!--      TODO: add themeClass-->
                <!--      TODO: need to be able to edit theme -->
                <image-panel v-if="selected && selected.blockType === 'ImageBlock'" @input="updateValue" />

                <style-panel
                  :type="selected.blockType"
                  :cssStyle="selected.blockStyle"
                  v-if="selected"
                  @input="updateStyles" />
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
<script>
import './styles/proposals.scss'
import { mapState } from 'vuex'
import Viewport from './viewport/Viewport'
import StylePanel from './panel/Style'
import ImagePanel from './panel/Image'
import NestedTree from './panel/NestedTree'
import AddComponentPanel from './panel/AddComponentWidget'
import TextMenuWidget from './panel/TextMenuWidget'
import ProposalTemplate from './ProposalTemplate'
import { ProposalActions, ProposalMutations } from './store'
import { apiRequest } from '@/helpers/helpers'
import { AppMutations } from '@/stores/AppStore'
import { VuexUndoRedoMixin } from './mixin/VuexUndoRedoMixin'

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

export default {
  name: 'ProposalDesigner',
  components: {
    ProposalTemplate,
    Viewport,
    StylePanel,
    ImagePanel,
    NestedTree,
    AddComponentPanel,
    TextMenuWidget
  },
  mixins: [StyleFixerMixin, VuexUndoRedoMixin],
  created() {
    this.$store.dispatch(ProposalActions.FETCH_TEMPLATE)
  },
  data() {
    return {
      tabs: null,
      debug: false,
      editable: true,
      dragging: false
    }
  },
  computed: {
    selected() {
      return this.$store.getters.selectedBlock
    },
    parent() {
      return this.$store.getters.findById(this.selected.parentId)
    },
    pages() {
      return this.template?.filter(x => x.parentId === undefined)
    },
    isSaveable() {
      return this.$store.getters.modifiedBlocks?.length > 0
    },
    activeEditor() {
      return this.$store.getters.activeEditor
    },
    ...mapState({
      template: (state) => state.proposal.template
    })
  },
  methods: {
    addComponent({ blockType, blockTypeId, blockValue }) {
      this.$store.commit(ProposalMutations.ADD_COMPONENT, {
        parentId: this.selected.id,
        blockType,
        blockTypeId,
        blockValue,
        order: 1
      })
    },
    updateValue(value) {
      this.$store.commit(ProposalMutations.SET_VALUE, { blockId: this.selected.id, value })
    },
    updateStyles(styles) {
      this.$store.commit(ProposalMutations.SET_STYLE, { blockId: this.selected.id, styles })
    },
    async downloadPreview() {
      try {

        this.$store.commit(AppMutations.SET_LOADING, true)
        const { data } = await apiRequest('blueraven', {
          method: 'post',
          url: '/proposal-preview/1',
          responseType: 'blob'
        })

        if (data) {
          const pdfFile = URL.createObjectURL(new Blob([data], { type: 'application/pdf' }))
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
        this.$snackbar('ERROR', e?.data?.message || 'Error while generating preview')
        console.error(e)
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async save() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      await this.$store.dispatch(ProposalActions.SAVE_TEMPLATE)
      this.reset()
      this.$store.commit(AppMutations.SET_LOADING, false)
    },
    selectNode(id) {
      this.$store.commit(ProposalMutations.SET_SELECTED, id)
      // this.focusNode(id)
    },
    focusViewport() {
      if (!this.selected) {
        return
      }

      this.focusNode(this.selected.id)
    },
    focusNode(id) {
      const vp = this.$refs.viewport.$el
      const nodes = vp.querySelectorAll(`[data-id="${id}"]`)
      if (nodes.length > 0) {
        const rect = nodes[0].getBoundingClientRect()
        const top = vp.scrollTop + rect.top - 220
        vp.scrollTo({ top, behavior: 'smooth' })
      }
    }
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
  overflow: auto;
  height: calc(100vh - 115px);
}

//.dpi {
//  height: 1in;
//  width: 1in;
//  left: 100%;
//  position: fixed;
//  top: 100%;
//}
</style>
