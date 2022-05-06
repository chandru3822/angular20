import cloneDeep from 'lodash.clonedeep'
import { getRequestWithParams, postRequest } from '@/helpers/helpers'

export const ProposalActions = {
  FETCH_TEMPLATE: 'fetchTemplate',
  FETCH_TEMPLATE_CONTEXT : 'fetchTemplateContext',
  SAVE_TEMPLATE: 'saveTemplate'
}

export const ProposalMutations = {
  RESET: 'proposal::resetChanged',
  SET_SELECTED: 'proposal::setSelected',
  SET_STYLE: 'proposal::setStyle',
  SET_VALUE: 'proposal::setValue'
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
      selectedId: undefined
    }
  },
  mutations: {
    setTemplate(state, { template, theme }) {
      //store a copy of the original
      state._template = cloneDeep(template)
      state.template = template
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
    }
  },
  actions: {
    [ProposalActions.FETCH_TEMPLATE]: async ({ commit }) => {
      const { data } = await getRequestWithParams(`/proposal/template/1`, {}, 'blueraven', {})
      commit('setTemplate', { template: data?.blocks, theme: data?.theme?.themeStyle })
    },
    [ProposalActions.FETCH_TEMPLATE_CONTEXT]: async ({commit}, { proposalId })=>{
      const { data } = await getRequestWithParams(`/proposal/${proposalId}/template`, {}, 'blueraven', {})
      commit('setTemplate', { template: data?.blocks, theme: data?.theme?.themeStyle })
    },
    //TODO: handle errors better
    [ProposalActions.SAVE_TEMPLATE]: async ({ commit, state, getters }) => {
      const modifiedBlocks = getters.modifiedBlocks
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
