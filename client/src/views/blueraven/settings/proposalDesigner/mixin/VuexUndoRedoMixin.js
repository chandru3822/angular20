import { ProposalMutations } from '../store'
import cloneDeep from 'lodash.clonedeep'

export const VuexUndoRedoMixin = {
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
