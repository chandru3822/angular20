<template>
  <v-row class="pane" align-content="start">
    <fragment v-if="type === 'TextBlock'">
      <v-col cols="12" sm="12">
        <v-select
          v-model="cssStyle.textAlign"
          :items="textAlignItems"
          label="Text Align"
          @change="doUpdateStyles({'textAlign': $event})"
        />
      </v-col>
      <v-col cols="12" sm="12">
        <font-size-widget :value="cssStyle.fontSize" @input="doUpdateStyles($event)" />
      </v-col>
      <v-col cols="12" sm="12">
        <color-widget :value="cssStyle.color" @input="doUpdateStyles($event)">
          <template #title>
            <span class="flex-grow-1">
            Font Color
            </span>
          </template>
        </color-widget>
      </v-col>

    </fragment>
    <!--    TODO: text transform-->
    <!--    TODO: border -->
    <!--    TODO: margin -->
    <!--    TODO: padding -->
    <!--    TODO: width -->
    <!--    TODO: more flex options (esp when parent is flex container) -->

    <!--    -->
    <fragment v-if="type === 'PageBlock' || type === 'ContainerBlock'">
      <image-selector-widget ref="imageSelector" />
      <v-btn @click="openSelectImage('@backgroundImage')">Open Image</v-btn>
      <v-btn text @click="doUpdateStyles({'@backgroundImage' : undefined })">Clear Image</v-btn>

      <v-col cols="12" sm="12" v-if="cssStyle.backgroundImage">
        <v-select
          v-model="cssStyle.backgroundSize"
          :items="backgroundSizeItems"
          label="Background Size"
          @change="doUpdateStyles({'backgroundSize': $event})"
        />
      </v-col>
      <!--      TODO: backgroundPosition-->
    </fragment>

    <v-col cols="12" sm="12">
      <v-select
        v-model="cssStyle.display"
        :items="displayItems"
        label="Display"
        @change="doUpdateStyles({'display': $event})"
      />
    </v-col>


    <!--    TODO: needs to take a string / needs a unit 'px'  / 'vw' / etc-->
    <!--    <v-col cols="12" sm="12">-->
    <!--      <v-subheader class="pl-0">-->
    <!--        Width-->
    <!--      </v-subheader>-->
    <!--      <v-slider-->
    <!--        dense-->
    <!--        thumb-label-->
    <!--        v-model="cssStyle.width"-->
    <!--        max="100"-->
    <!--        min="0"-->
    <!--      />-->
    <!--    </v-col>-->

    <!--    TODO: support grid ... somehow -->

    <fragment v-if="isFlex">
      <v-col cols="12" sm="12" v-if="isFlex">
        <v-select
          v-model="cssStyle.flexDirection"
          :items="flexDirectionItems"
          label="Direction"
          @change="doUpdateStyles({'flexDirection': $event})"
        />
      </v-col>
      <v-col cols="12" sm="12" v-if="isFlex">
        <v-select
          v-model="cssStyle.justifyContent"
          :items="flexJustifyItems"
          label="Justify"
          @change="doUpdateStyles({'justifyContent': $event})"
        />
      </v-col>
      <v-col cols="12" sm="12" v-if="isFlex">
        <v-select
          v-model="cssStyle.alignItems"
          :items="flexAlignItems"
          label="Align"
          @change="doUpdateStyles({'alignItems': $event})"
        />
      </v-col>
    </fragment>
  </v-row>
</template>
<script>
import ImageSelectorWidget from './ImageSelectorWidget'
import FontSizeWidget from './FontSizeWidget'
import ColorWidget from './ColorWidget'
import { Fragment } from 'vue-frag'

export default {
  props: {
    type: {
      type: String,
      required: true
    },
    cssStyle: {
      type: Object,
      required: false,
      default: function() {
        return {}
      }
    }
  },
  components: { Fragment, FontSizeWidget, ColorWidget, ImageSelectorWidget },
  computed: {
    isFlex() {
      return this.cssStyle?.display === 'flex'
    }
  },
  mounted() {
    this.style = { ...this.cssStyle }
  },
  data() {
    return {
      style: {},
      textAlignItems: ['left', 'center', 'right', 'justify'],
      displayItems: ['block', 'flex'],
      flexDirectionItems: ['row', 'row-reverse', 'column', 'column-reverse'],
      flexJustifyItems: ['flex-start', 'space-between', 'center', 'space-around', 'flex-end'],
      flexAlignItems: ['flex-start', 'center', 'flex-end'],
      backgroundSizeItems: ['auto', 'contain', 'cover']
    }
  },
  methods: {
    doUpdateStyles(styles) {
      this.$emit('input', { ...this.cssStyle, ...styles })
    },
    async openSelectImage(attribute = '@backgroundImage') {
      const result = await this.$refs.imageSelector.open()
      if (result?.uuid !== undefined) {
        this.doUpdateStyles({ [attribute]: result.uuid })
      }
    }
  }
}
</script>
<style lang="scss" scoped>
.pane {
  border-bottom: 1px solid #f5f5f5;
}
</style>
