import '@tiptap/extension-text-style'

import {Extension, generateHTML, mergeAttributes} from '@tiptap/core'
import StarterKit from '@tiptap/starter-kit'
import TextStyle from '@tiptap/extension-text-style'
import Superscript from '@tiptap/extension-superscript'
import TextAlign from '@tiptap/extension-text-align'
import Mention from '@tiptap/extension-mention'
import Table from '@tiptap/extension-table'
import TableCell from '@tiptap/extension-table-cell'
import TableRow from '@tiptap/extension-table-row'
import TableHeader from '@tiptap/extension-table-header'
import {VueRenderer} from '@tiptap/vue-2'
import tippy from 'tippy.js'
import Fuse from 'fuse.js'
import ReplacementList from './ReplacementList'


const FontConfig = Extension.create({
  name: 'fontConfig',

  addOptions() {
    return {
      types: ['textStyle']
    }
  },

  addGlobalAttributes() {
    return [
      {
        types: this.options.types,
        attributes: {
          color: {
            default: null,
            parseHTML: element => element.style.color?.replace(/['"]+/g, ''),
            renderHTML: attributes => {
              if (!attributes.color) {
                return {}
              }

              return {
                style: `color: ${attributes.color}`
              }
            }
          },
          fontSize: {
            default: null,
            parseHTML: element => element.style.fontSize?.replace(/['"]+/g, ''),
            renderHTML: attributes => {
              if (!attributes.fontSize) {
                return {}
              }

              return {
                style: `font-size: ${attributes.fontSize}`
              }
            }
          },
          fontWeight: {
            default: null,
            parseHTML: element => element.style.fontWeight?.replace(/['"]+/g, ''),
            renderHTML: attributes => {
              if (!attributes.fontWeight) {
                return {}
              }

              return {
                style: `font-weight: ${attributes.fontWeight}`
              }
            }
          }
        }
      }
    ]
  },

  addCommands() {
    return {
      setFontColor: color => ({chain}) => {
        return chain()
          .setMark('textStyle', {color})
          .run()
      },
      unsetFontColor: () => ({chain}) => {
        return chain()
          .setMark('textStyle', {color: null})
          .removeEmptyTextStyle()
          .run()
      },

      setFontSize: fontSize => ({chain}) => {
        return chain()
          .setMark('textStyle', {fontSize})
          .run()
      },
      unsetFontSize: () => ({chain}) => {
        return chain()
          .setMark('textStyle', {fontSize: null})
          .removeEmptyTextStyle()
          .run()
      },

      setFontWeight: fontWeight => ({chain}) => {
        return chain()
          .setMark('textStyle', {fontWeight})
          .run()
      },
      unsetFontWeight: () => ({chain}) => {
        return chain()
          .setMark('textStyle', {fontWeight: null})
          .removeEmptyTextStyle()
          .run()
      }
    }
  }
})

const suggestion = ({tags = []}) => ({
  char: '{',
  endChar: '}',
  items: ({query}) => {
    if (query === '') {
      return tags.slice(0, 10)
    }
    const fuse = new Fuse(tags, {includeScore: true, threshold: 0.4, distance: 75})
    return fuse.search(query).map(({item}) => item).slice(0, 10)
  },

  render: () => {
    let component
    let popup
    return {
      onStart: (props) => {
        component = new VueRenderer(ReplacementList, {
          parent: this,
          propsData: props
        })
        popup = tippy('body', {
          getReferenceClientRect: props.clientRect,
          appendTo: () => document.body,
          content: component.element,
          showOnCreate: true,
          interactive: true,
          trigger: 'manual',
          placement: 'bottom-start',
          maxWidth: 'none'
        })
      },

      onUpdate(props) {
        component.updateProps(props)

        popup[0].setProps({
          getReferenceClientRect: props.clientRect
        })
      },

      onKeyDown(props) {
        props.event.stopPropagation()

        if (props.event.key === 'Escape') {
          popup[0].hide()
          return true
        }

        return component.ref?.onKeyDown(props)
      },

      onExit() {
        setTimeout(() => {
          popup[0].destroy()
          component.destroy()
        }, 100)

      }
    }
  }
})

const extensions = [
  StarterKit,
  Superscript,
  TextStyle,
  FontConfig,
  TextAlign.configure({
    types: [],
    defaultAlignment: ''
  }),
  Table.configure({
    resizable: true
  }),
  TableCell,
  TableRow,
  TableHeader
]

const generateHTMLFromJSON = (json) => {
  const extensions = getExtensions()
  return generateHTML(json, extensions)
}

const getExtensions = ({tags = []} = {}) => {

  Mention.config.renderHTML = function ({node, HTMLAttributes}) {
    return [
      'span',
      mergeAttributes({'data-type': this.name, title: node.attrs.label ?? node.attrs.id}, this.options.HTMLAttributes, HTMLAttributes),
      this.options.renderLabel({
        options: this.options,
        node
      })
    ]
  }

  const mention = Mention.configure({
    suggestion: suggestion({tags}),
    renderLabel({options, node}) {
      return `${options.suggestion.char}VARIABLE${options.suggestion.endChar}`
    },
    HTMLAttributes: {
      class: 'replacement'
    }
  })

  return [...extensions, mention]
}

export {getExtensions, extensions, generateHTMLFromJSON}
