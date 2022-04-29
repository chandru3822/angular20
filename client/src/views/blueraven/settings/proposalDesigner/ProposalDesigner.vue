<template>
  <div>
    <div class="toolbar">
      <!--    <label><input type="checkbox" v-model="editable" />Editable</label>-->
      <!--    <label><input type="checkbox" v-model="debug" /> Debug</label>-->
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
          <v-btn v-bind="attrs" v-on="on" @click="downloadPreview" icon text>
            <v-icon>mdi-file-pdf-box</v-icon>
          </v-btn>
        </template>
        <span>Generate PDF Preview</span>
      </v-tooltip>
    </div>
    <div class="proposal-designer">
      <viewport>
        <proposal-template v-if="pages && pages.length > 0" :children="pages" :debug="debug" :editable="editable" />
      </viewport>
      <panel>
        <!--      TODO: add themeClass-->
        <!--      TODO: need to be able to edit theme -->
        <image-panel v-if="selected && selected.blockType === 'ImageBlock'" @input="updateValue" />

        <style-panel
          :type="selected.blockType"
          :cssStyle="selected.blockStyle"
          v-if="selected"
          @input="updateStyles" />
      </panel>
    </div>
  </div>
</template>
<script>
import './styles/proposals.scss'
import { mapState } from 'vuex'
import Viewport from './viewport/Viewport'
import Panel from './panel/Panel'
import StylePanel from './panel/Style'
import ImagePanel from './panel/Image'
import ProposalTemplate from './ProposalTemplate'
import { ProposalActions, ProposalMutations } from './store'
import { apiRequest } from '@/helpers/helpers'
import { AppMutations } from '@/stores/AppStore'
import cloneDeep from 'lodash.clonedeep'

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

const VuexUndoRedoMixin = {
  data() {
    return {
      done: [],
      undone: [],
      newMutation: true
    }
  },
  mounted() {
    this._keyListener = function(e) {
      if (e.key === 'z' && (e.ctrlKey || e.metaKey)) {
        e.preventDefault()
        if (this.canUndo) {
          this.undo()
        }
      }

      if (e.key === 'z' && e.shiftKey && (e.ctrlKey || e.metaKey)) {
        e.preventDefault()
        if (this.canRedo) {
          this.redo()
        }
      }
    }
    document.addEventListener('keydown', this._keyListener.bind(this))
  },
  beforeDestroy() {
    document.removeEventListener('keydown', this._keyListener)
  },
  created() {
    if (this.$store) {
      this.$store.subscribe((mutation) => {
        if ([ProposalMutations.SET_VALUE, ProposalMutations.SET_STYLE].includes(mutation.type)) {
          const commit = cloneDeep(mutation)
          this.done.push(commit)
        }

        if (this.newMutation) {
          this.undone = []
        }
      })
    }
  },
  computed: {
    canRedo() {
      return this.undone.length > 0
    },
    canUndo() {
      return this.done.length > 0
    }
  },
  methods: {
    redo() {
      let mutation = this.undone.pop()
      this.newMutation = false
      this.$store.commit(mutation.type, { ...mutation.payload })
      this.newMutation = true
    },
    undo() {
      this.undone.push(this.done.pop())
      this.newMutation = false
      //reset state
      this.$store.commit(ProposalMutations.RESET)
      this.done.forEach(mutation => {
        this.$store.commit(mutation.type, mutation.payload)
        this.done.pop()
      })
      this.newMutation = true
    },
    reset() {
      this.$store.commit(ProposalMutations.RESET)
      this.undone = []
      this.done = []
    }
  }
}

export default {
  name: 'ProposalDesigner',
  components: { ProposalTemplate, Viewport, Panel, StylePanel, ImagePanel },
  mixins: [StyleFixerMixin, VuexUndoRedoMixin],
  created() {
    this.$store.dispatch(ProposalActions.FETCH_TEMPLATE)
  },
  data() {
    return {
      debug: false,
      editable: true
    }
  },
  computed: {
    selected() {
      return this.$store.getters.selectedBlock
    },
    pages() {
      return this.template?.filter(x => x.parentId === undefined)
    },
    isSaveable() {
      return this.$store.getters.modifiedBlocks?.length > 0
    },
    ...mapState({
      template: (state) => state.proposal.template
    })
  },
  methods: {
    updateValue(value) {
      this.$store.commit(ProposalMutations.SET_VALUE, { blockId: this.selected.id, value })
    },
    updateStyles(styles) {
      this.$store.commit(ProposalMutations.SET_STYLE, { blockId: this.selected.id, styles })
    },
    async downloadPreview() {
      try {

        this.$store.commit(AppMutations.SET_LOADING, true)

        const theme = this.$store.getters.theme
        const template = this.$store.state.proposal.template

        const { data } = await apiRequest('blueraven', {
          method: 'post',
          url: '/proposal-preview',
          responseType: 'blob',
          data: {
            template,
            theme
          }
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
    }
  }
}
</script>
<style lang="scss">
.toolbar {
  position: sticky;
  top: 0;
  z-index: 100;
  background-color: white;
  padding: 10px;
}

.proposal-designer {
  display: flex;
  //TODO: reset
  // change font color to black by default
  & p {
    margin: 0 !important;
    padding: 0 !important;
  }
}
</style>
