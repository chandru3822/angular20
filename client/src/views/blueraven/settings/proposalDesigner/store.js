import { defineStore } from 'pinia'
import { computed, ref } from 'vue'
import cloneDeep from 'lodash.clonedeep'
import {
  getRequest,
  getRequestWithParams,
  postRequest
} from '@/helpers/helpers.js'

const removedUndefined = (object) => {
  if (!object) {
    return object
  }

  return (
    Object.keys(object)
      //remove the keys if they are cleared out
      .filter((key) => object[key] !== undefined)
      .reduce((obj, key) => {
        obj[key] = object[key]
        return obj
      }, {})
  )
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

export default defineStore('proposalStore', () => {
  //a copy of the original
  const _template = ref([])
  const template = ref([])
  const theme = ref({})
  const selectedId = ref(undefined)
  const tags = ref([])
  const loading = ref(false)
  const modifiedBlocks = computed(() =>
    template.value
      .filter((b) => b.modified === true)
      .map((b) => {
        b.blockStyle = removedUndefined(b.blockStyle)
        return b
      })
  )
  const selectedBlock = computed(() =>
    template.value.find((b) => b.id === selectedId.value)
  )

  const done = ref([])
  const undone = ref([])
  const newMutation = ref(true)

  const canRedo = computed(() => undone.value.length > 0)
  const canUndo = computed(() => done.value.length > 0)

  const findById = (id) => {
    if (!id) return null
    return template.value.find((b) => b.id === id)
  }

  const filterByParentId = (parentId) => {
    return template.value.filter((b) => b.parentId === parentId)
  }

  const asJson = () => {
    return blocksToJson(template.value)
  }

  const setBaseline = (state) => {
    _template.value = cloneDeep(state?.template)
    template.value = [...state?.template]
    theme.value = { ...state?.theme }
  }

  const setTemplate = (tmpl) => {
    template.value = [...tmpl]
    done.value.push(cloneDeep(template.value))
  }

  const reset = () => {
    template.value = cloneDeep(_template.value)
    undone.value = []
    done.value = []
  }

  const setSelected = (id) => {
    selectedId.value = id
  }

  const addBlock = (block, order) => {
      const found = findById(block.id)
      if(!found){
          template.value.push(block)
          done.value.push(cloneDeep(template.value))
      }
  }

  const setStyle = ({ blockId, styles }) => {
    const found = findById(blockId)
    if (found) {
      template.value = template.value.map((block) => {
        if (block.id !== blockId) {
          return block
        }
        return { ...block, modified: true, blockStyle: styles }
      })

      done.value.push(cloneDeep(template.value))
    }
  }

  const setValue = ({ blockId, value }) => {
      debugger
    const found = findById(blockId)
    if (found) {
      template.value = template.value.map((block) => {
        if (block.id !== blockId) {
          return block
        }
        return { ...block, modified: true, blockValue: cloneDeep(value) }
      })
      done.value.push(cloneDeep(template.value))
    }

  }

  const setName = ({ blockId, name }) => {
    const found = findById(blockId)
    if (found) {
      template.value = template.value.map((block) => {
        if (block.id !== blockId) {
          return block
        }
        return { ...block, modified: true, blockName: name, displayName: writeDisplayName({...block, blockName: name}) }
      })
      done.value.push(cloneDeep(template.value))
    }
  }

  const writeDisplayName = (block) => {
      return `#${ block.id } - ${block.blockName ? block.blockName : 'Unnamed'}: ${ block.blockType }(${block.blockOrder})`
  }

  const setVisibility = ({ blockId, visibility }) => {
    const found = findById(blockId)
    if (found) {
      template.value = template.value.map((block) => {
        if (block.id !== blockId) {
          return block
        }
        return { ...block, modified: true, visibility }
      })
      done.value.push(cloneDeep(template.value))
    }
  }

  const updatePosition = ({ blockId, parentId, position }) => {
    const found = findById(blockId)
    if (found) {
      template.value = template.value.map((block) => {
        if (block.id !== blockId) {
          return block
        }
        return { ...block, modified: true, blockOrder: position, parentId }
      })
      done.value.push(cloneDeep(template.value))
    }
  }

  const fetchTemplate = async () => {
    try {
      loading.value = true
      const { data } = await getRequestWithParams(
        `/proposal/template/1`,
        {},
        'blueraven',
        {}
      )
        for(let b of data?.blocks){
            b.displayName = writeDisplayName(b)
        }

      //set as baseline
      setBaseline({
        template: data?.blocks,
        theme: data?.theme?.themeStyle
      })
    } catch (e) {
      //clear baseline
      setBaseline({
        template: [],
        theme: {}
      })

      console.error(e)
    } finally {
      loading.value = false
    }
  }

  const fetchTemplateContext = async ({ proposalId }) => {
    try {
      loading.value = true
      const { data } = await getRequestWithParams(
        `/proposal/${proposalId}/template`,
        {},
        'blueraven',
        {}
      )

      //establish baseline
      setBaseline({
        template: data?.blocks,
        theme: data?.theme?.themeStyle
      })
    } catch (e) {
      //clear baseline
      setBaseline({
        template: [],
        theme: {}
      })
      console.error(e)
    } finally {
      loading.value = false
    }
  }

  const saveTemplate = async () => {
    try {
      if (modifiedBlocks.value.length > 0) {
        const { data } = await postRequest(
          `/proposal/template/1/blocks`,
          { blocks: modifiedBlocks.value },
          'blueraven'
        )
        if (data) {
          const updated = data?.reduce((acc, obj) => {
            const key = obj?.id
            if (!acc[key]) {
              acc[key] = obj
            }
            return acc
          }, {})

          const t = template.value.map((b) => {
            return updated[b.id] ? updated[b.id] : b
          })
          //set template as original
          _template.value = cloneDeep(t)
          //reset so this becomes the new baseline
          reset()
        }
      }
    } catch (e) {
      console.error(e)
    }
  }

  const fetchTags = async () => {
    try {
      const { data } = await getRequest(
        '/proposal/template/tags',
        'blueraven',
        []
      )
      tags.value = [...data]
    } catch (e) {
      tags.value = []
    }
  }

  const redo = function () {
    const mutation = undone.value.pop()
    newMutation.value = false
    template.value = [...mutation]
    newMutation.value = true
  }

  const undo = function () {
    const mutation = done.value.pop()
    undone.value.push(mutation)
    newMutation.value = false
    template.value = [...mutation]
    newMutation.value = true
  }

  return {
    template,
    _template,
    theme,
    selectedId,
    tags,
    loading,
    modifiedBlocks,
    selectedBlock,
    findById,
    filterByParentId,
    asJson,
    reset,
    setSelected,
      addBlock,
    setTemplate,
    setStyle,
    setValue,
    setName,
    setVisibility,
    updatePosition,
    fetchTemplate,
    fetchTemplateContext,
    saveTemplate,
    fetchTags,
    undo,
    redo,
    canRedo,
    canUndo
  }
})
