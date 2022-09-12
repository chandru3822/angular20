<template>
  <div class="d-flex flex-column justify-center align-center">
    <div>
      <v-btn icon @click="editor.chain().focus().toggleBold().run()" :class="{ 'is-active': editor.isActive('bold') }">
        <v-icon>mdi-format-bold</v-icon>
      </v-btn>
      <v-btn icon @click="editor.chain().focus().toggleItalic().run()"
             :class="{ 'is-active': editor.isActive('italic') }">
        <v-icon>mdi-format-italic</v-icon>
      </v-btn>
      <v-btn icon @click="editor.chain().focus().toggleStrike().run()"
             :class="{ 'is-active': editor.isActive('strike') }">
        <v-icon>mdi-format-strikethrough</v-icon>
      </v-btn>

<!--      <v-btn icon @click="editor.chain().focus().setParagraph().run()"-->
<!--             :class="{ 'is-active': editor.isActive('paragraph') }">-->
<!--        <v-icon>mdi-format-paragraph</v-icon>-->
<!--      </v-btn>-->
      <v-btn icon @click="editor.chain().focus().toggleSuperscript().run()"
             :class="{ 'is-active': editor.isActive('superscript') }">
        <v-icon>mdi-format-superscript</v-icon>
      </v-btn>
      <v-btn icon @click="editor.chain().focus().toggleBulletList().run()"
             :class="{ 'is-active': editor.isActive('bulletList') }">
        <v-icon>mdi-format-list-bulleted</v-icon>
      </v-btn>
      <v-btn icon @click="editor.chain().focus().toggleOrderedList().run()"
             :class="{ 'is-active': editor.isActive('orderedList') }">
        <v-icon>mdi-format-list-numbered</v-icon>
      </v-btn>

      <v-btn icon @click="editor.chain().focus().setHorizontalRule().run()">
        <v-icon>mdi-minus</v-icon>
      </v-btn>
    </div>

    <div>
      <v-btn icon @click="editor.chain().focus().insertTable({ rows: 4, cols: 2 }).run()">
        <v-icon>mdi-table-plus</v-icon>
      </v-btn>
      <v-btn icon @click="editor.chain().focus().addColumnBefore().run()" :disabled="!editor.can().addColumnBefore()">
        <v-icon>mdi-table-column-plus-before</v-icon>
      </v-btn>
      <v-btn icon @click="editor.chain().focus().addColumnAfter().run()" :disabled="!editor.can().addColumnAfter()">
        <v-icon>mdi-table-column-plus-after</v-icon>
      </v-btn>
      <v-btn icon @click="editor.chain().focus().deleteColumn().run()" :disabled="!editor.can().deleteColumn()">
        <v-icon>mdi-table-column-remove</v-icon>
      </v-btn>
      <v-btn icon @click="editor.chain().focus().addRowBefore().run()" :disabled="!editor.can().addRowBefore()">
        <v-icon>mdi-table-row-plus-before</v-icon>
      </v-btn>
      <v-btn icon @click="editor.chain().focus().addRowAfter().run()" :disabled="!editor.can().addRowAfter()">
        <v-icon>mdi-table-row-plus-after</v-icon>
      </v-btn>
      <v-btn icon @click="editor.chain().focus().deleteRow().run()" :disabled="!editor.can().deleteRow()">
        <v-icon>mdi-table-row-remove</v-icon>
      </v-btn>
      <v-btn icon @click="editor.chain().focus().deleteTable().run()" :disabled="!editor.can().deleteTable()">
        <v-icon>mdi-table-remove</v-icon>
      </v-btn>
      <v-btn icon @click="editor.chain().focus().mergeCells().run()" :disabled="!editor.can().mergeCells()">
        <v-icon>mdi-table-merge-cells</v-icon>
      </v-btn>
      <v-btn icon @click="editor.chain().focus().splitCell().run()" :disabled="!editor.can().splitCell()">
        <v-icon>mdi-table-split-cell</v-icon>
      </v-btn>

      <!--      <v-btn icon @click="editor.chain().focus().mergeOrSplit().run()" :disabled="!editor.can().mergeOrSplit()">-->
      <!--        mergeOrSplit-->
      <!--        <v-icon>mdi-table-column-remove</v-icon>-->

      <!--      </v-btn>-->
      <!--          TODO: run this before saving if there is a table-->
      <!--          <v-btn @click="editor.chain().focus().fixTables().run()" :disabled="!editor.can().fixTables()">-->
      <!--            fixTables-->
      <!--          </v-btn>-->
    </div>
  </div>
</template>
<script>
export default {
  props: {
    editor: {
      type: Object,
      required: true
    }
  }
}
</script>
<style lang="scss" scoped>
.is-active {
  background-color: #d0d0d066;
}
</style>
