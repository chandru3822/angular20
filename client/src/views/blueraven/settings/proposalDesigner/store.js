import cloneDeep from 'lodash.clonedeep'
import { getRequestWithParams, getSnackbar, postRequest } from '@/helpers/helpers'
import { AppMutations } from '@/stores/AppStore'

export const ProposalActions = {
  FETCH_TEMPLATE: 'fetchTemplate',
  FETCH_TEMPLATE_CONTEXT: 'fetchTemplateContext',
  SAVE_TEMPLATE: 'saveTemplate'
}

export const ProposalMutations = {
  RESET: 'proposal::resetChanged',
  SET_SELECTED: 'proposal::setSelected',
  SET_STYLE: 'proposal::setStyle',
  SET_VALUE: 'proposal::setValue',
  ADD_COMPONENT: 'proposal::addComponent',
  REGISTER_EDITOR: 'proposal::registerEditor',
  DEREGISTER_EDITOR: 'proposal::deRegisterEditor',
  UPDATE_POSITION: 'proposal:updatePosition'
}

const removedUndefined = (object) => {
  if (!object) {
    return object
  }

  return Object.keys(object)
    //remove the keys if they are cleared out
    .filter(key => object[key] !== undefined)
    .reduce((obj, key) => {
      obj[key] = object[key]
      return obj
    }, {})
}

const blocksToJson = (blocks = []) => {
  const items = [...blocks]
  const root = items.filter((i) => !i.parent)

  // eslint-disable-next-line no-unused-vars
  const jsonsify = ({ id, parent, ...block }) => {
    const children = items.filter((i) => i.parent === id)
    const item = { ...block }
    if (children.length) {
      item.children = children.map(jsonsify)
    }
    return item
  }
  return root.map(jsonsify)
}

export default {
  state: () => {
    return {
      _template: [],
      template: [],
      theme: {},
      selectedId: undefined,
      editors: {}
    }
  },
  mutations: {
    setTemplate(state, { template, theme }) {
      //store a copy of the original
      state._template = cloneDeep(template)
      // state.template = template
      // TODO: figure out why this doesn't reload
      state.template = Object.assign([], template)
      state.theme = theme
    },
    [ProposalMutations.RESET](state) {
      state.template = cloneDeep(state._template)
    },
    [ProposalMutations.SET_SELECTED](state, selectedId) {
      state.selectedId = selectedId
    },
    [ProposalMutations.SET_STYLE](state, { blockId, styles }) {
      const found = state.template.find(block => block.id === blockId)
      if (found) {
        state.template = state.template.map(block => {
          if (block.id !== blockId) {
            return block
          }
          return { ...block, modified: true, blockStyle: styles }
        })
      }
    },
    [ProposalMutations.SET_VALUE](state, { blockId, value }) {
      const found = state.template.find(block => block.id === blockId)
      if (found) {
        state.template = state.template.map(block => {
          if (block.id !== blockId) {
            return block
          }
          return { ...block, modified: true, blockValue: cloneDeep(value) }
        })
      }
    },
    // [ProposalMutations.ADD_COMPONENT](state, { blockType, blockTypeId, blockValue, blockStyle, blockOrder, parentId }) {
    //   const newBlock = {
    //     id: 99999,
    //     blockType,
    //     blockTypeId,
    //     blockValue,
    //     blockStyle,
    //     blockOrder,
    //     parentId
    //   }
    //   console.log({ newBlock })
    //   state.template = [...state.template, newBlock]
    // },
    [ProposalMutations.UPDATE_POSITION](state, { blockId, parentId, pos }) {
      const found = state.template.find(block => block.id === blockId)
      console.log({found: found.blockOrder, blockId, parentId, pos})
      if (found) {
        state.template = state.template.map(block => {
          if (block.id !== blockId) {
            return block
          }
          return { ...block, blockOrder: pos, parentId, modified: true }
        })
      }
    },
    [ProposalMutations.REGISTER_EDITOR](state, { blockId, editor }) {
      if (state.editors === undefined) {
        state.editors = {}
      }
      state.editors[blockId] = editor
    },
    [ProposalMutations.DEREGISTER_EDITOR](state, { blockId }) {
      delete state.editors[blockId]
    }
  },
  actions: {
    [ProposalActions.FETCH_TEMPLATE]: async ({ commit }) => {
      const { data } = await getRequestWithParams(`/proposal/template/1`, {}, 'blueraven', {})
      commit('setTemplate', { template: data?.blocks, theme: data?.theme?.themeStyle })
    },
    [ProposalActions.FETCH_TEMPLATE_CONTEXT]: async ({ commit }, { proposalId }) => {
      try {
        const { data } = await getRequestWithParams(`/proposal/${proposalId}/template`, {}, 'blueraven', {})
        commit('setTemplate', { template: data?.blocks, theme: data?.theme?.themeStyle })
      } catch (e) {
        const snackbar = getSnackbar('ERROR', e?.data?.message || 'Error retrieving template')
        commit(AppMutations.SHOW_SNACK, snackbar)
      }
    },
    //TODO: handle errors better
    [ProposalActions.SAVE_TEMPLATE]: async ({ commit, state, getters }) => {
      const modifiedBlocks = getters.modifiedBlocks?.map(block => {
        block.blockStyle = removedUndefined(block.blockStyle)
        return block
      })

      if (modifiedBlocks.length > 0) {
        const { data } = await postRequest(`/proposal/template/1/blocks`, { blocks: modifiedBlocks }, 'blueraven')
        if (data) {
          const updated = data?.reduce((acc, obj) => {
            const key = obj?.id
            if (!acc[key]) {
              acc[key] = obj
            }
            return acc
          }, {})

          const template = state.template.map(b => {
            return updated[b.id] ? updated[b.id] : b
          })
          commit('setTemplate', { template, theme: state?.theme })
        }
      }
    }
  },
  getters: {
    modifiedBlocks(state) {
      return state.template.filter(b => b.modified === true)
    },

    selectedBlock(state) {
      return state.template.find((b) => b.id === state.selectedId)
    },

    activeEditor(state, getters) {
      if (!getters.selectedBlock) {
        return null
      }
      return state.editors[getters.selectedBlock.id] ?? null
    },

    findById: (state) => (id) => {
      if (!id) return null
      return state.template.find(b => b.id === id)
    },

    filterByParentId: (state) => (parentId) => {
      return state.template.filter((b) => b.parentId === parentId)
    },

    theme(state) {
      return state.theme
    },

    asJson: (state) => () => {
      return blocksToJson(state.template)
    }
  }
}
