<template>
  <fragment>
    <fragment v-if="type === 'TextBlock'">
      <div>
        <v-card-title>Typography</v-card-title>
        <v-btn-toggle v-model="cssStyle.textAlign">
          <v-btn small value="left">
            <v-icon>mdi-format-align-left</v-icon>
          </v-btn>

          <v-btn small value="center">
            <v-icon>mdi-format-align-center</v-icon>
          </v-btn>

          <v-btn small value="right">
            <v-icon>mdi-format-align-right</v-icon>
          </v-btn>

          <v-btn small value="justify">
            <v-icon>mdi-format-align-justify</v-icon>
          </v-btn>
        </v-btn-toggle>

        <v-text-field outlined dense
          v-model="cssStyle.fontWeight"
          label="Font Weight"
          @change="doUpdateStyles({'fontWeight': $event})"
        />
        <v-text-field outlined dense
                      v-model="cssStyle.lineHeight"
                      label="Line Height"
                      @change="doUpdateStyles({'lineHeight': $event})"
        />
        <size-widget label="Font Size" attr="fontSize" :value="cssStyle.fontSize" @input="doUpdateStyles($event)" />

      </div>

      <div>
        <v-card-title>Colors</v-card-title>
        <color-widget :value="cssStyle.color" @input="doUpdateStyles($event)">
          <template #title>
            <span class="flex-grow-1">
            Font Color
            </span>
          </template>
        </color-widget>

        <color-widget :value="cssStyle.backgroundColor" attr="backgroundColor" @input="doUpdateStyles($event)">
          <template #title>
            <span class="flex-grow-1">
            Background Color
            </span>
          </template>
        </color-widget>
      </div>

    </fragment>
    <!--    -->
    <fragment v-if="type === 'PageBlock' || type === 'ContainerBlock'">
      <div>
        <v-card-title>Background</v-card-title>
        <div>
          <image-selector-widget ref="imageSelector" />
          <v-btn @click="openSelectImage('@backgroundImage')">Open Image</v-btn>
          <v-btn text @click="doUpdateStyles({'@backgroundImage' : undefined })">Clear Image</v-btn>
        </div>

        <v-select dense
          v-if="cssStyle.backgroundImage"
          v-model="cssStyle.backgroundSize"
          :items="backgroundSizeItems"
          label="Background Size"
          @change="doUpdateStyles({'backgroundSize': $event})"
        />
      </div>
      <!--      TODO: backgroundPosition-->

    </fragment>

    <div>
      <v-card-title>Props</v-card-title>
      <v-select outlined dense
                v-model="cssStyle.display"
                :items="displayItems"
                label="Display"
                @change="doUpdateStyles({'display': $event})"
      />

      <fragment v-if="isFlex">
        <v-select outlined dense
                  v-model="cssStyle.flexDirection"
                  :items="flexDirectionItems"
                  label="Direction"
                  @change="doUpdateStyles({'flexDirection': $event})"
        />
        <v-select outlined dense
                  v-model="cssStyle.justifyContent"
                  :items="flexJustifyItems"
                  label="Justify"
                  @change="doUpdateStyles({'justifyContent': $event})"
        />
        <v-select outlined dense
                  v-model="cssStyle.alignItems"
                  :items="flexAlignItems"
                  label="Align"
                  @change="doUpdateStyles({'alignItems': $event})"
        />
        <v-text-field outlined dense
                      v-model="cssStyle.flexBasis"
                      label="Flex Basis"
                      @change="doUpdateStyles({'flexBasis': $event})"
        />
      </fragment>
    </div>

    <div>
      <v-card-title>Padding</v-card-title>
      <space-widget attr="padding" :value="cssStyle.padding" @input="doUpdateStyles($event)"/>
    </div>
  </fragment>
</template>
<script>
import ImageSelectorWidget from './ImageSelectorWidget'
import SizeWidget from './SizeWidget'
import ColorWidget from './ColorWidget'
import SpaceWidget from './SpaceWidget'
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
  components: { Fragment, SizeWidget, ColorWidget, ImageSelectorWidget, SpaceWidget },
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
      paddingToggle: null,
      displayItems: ['block', 'flex'],
      flexDirectionItems: ['row', 'row-reverse', 'column', 'column-reverse'],
      flexJustifyItems: ['flex-start', 'space-between', 'center', 'space-around', 'flex-end'],
      flexAlignItems: ['flex-start', 'center', 'flex-end'],
      backgroundSizeItems: ['auto', 'contain', 'cover']
    }
  },
  methods: {
    doUpdateStyles(styles) {
      // console.log({styles, applied: {...this.cssStyle, ...styles}})
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

</style>
