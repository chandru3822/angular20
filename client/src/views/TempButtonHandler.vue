<template>
  <v-main>
    <v-container>
      <v-row>
        <v-col cols="12">
          <h3 class="mb-5">Paste the v-btn code here</h3>
          <v-textarea v-model="vBtnValue" outlined @input="albatrossButtonValue = null"
                      label="V-BTN Value" />
          <AlbatrossButton
              :disabled="!vBtnValue"
              @click="processBtn" text="Submit"></AlbatrossButton>
          <AlbatrossButton class="ml-4" variant="text"
              @click="[vBtnValue = null, albatrossButtonValue = null]" text="Clear"></AlbatrossButton>
        </v-col>
      </v-row>

      <v-row>
        <v-col cols="12">
          <div class="d-flex">
            <h3 class="mb-5">Albatross Button Code</h3>
            <AlbatrossButton icon class="ml-5" color="primary"
                v-if="albatrossButtonValue"
                @click="copyToClipboard" prepend-icon="mdi-content-copy"></AlbatrossButton>
          </div>
          <v-textarea outlined v-model="albatrossButtonValue" auto-grow>
          </v-textarea>
        </v-col>
      </v-row>

    </v-container>
  </v-main>
</template>

<script setup>
import {getCurrentInstance, onMounted, ref} from 'vue'
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton"
import * as prettier from 'prettier'
import htmlParser from 'prettier/parser-html'

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const router = vueInstance.$router
const snackbar = vueInstance.$snackbar

const vBtnValue = ref(null)
const albatrossButtonValue = ref()

//for testing
// vBtnValue.value = '<v-btn text color="primary" class="text-capitalize" @click="toggleMinimizeAll"> {{ expandedAll !== CollapseExpandEnum.COLLAPSED ? \'Minimize All\' : \'Expand All\' }} </v-btn>'
// vBtnValue.value = ' <v-btn v-if="(userCanEdit || userIsAdmin) && selectedWorkQueueCategoryId !== -1" text color="primary"\n' +
//     '                         icon small class="handle">\n' +
//     '                    <v-icon>drag_handle</v-icon>\n' +
//     '                  </v-btn>'

const processBtn = async () => {
  let tempString = vBtnValue.value
  tempString = tempString.replaceAll('v-btn', 'AlbatrossButton')
  tempString = tempString.replaceAll(' text ', ' variant="text" ')
  tempString = tempString.replaceAll(' outlined ', ' variant="outlined" ')
  tempString = tempString.replaceAll('white--text', '')
  tempString = tempString.replaceAll('style', 'html-style')
  tempString = tempString.replaceAll('type', 'btn-type')
  let hardcodedSize = tempString.includes(' small ') ? 'small' : ''
  tempString = tempString.replaceAll(' small ', ' size="small" ')
  if(!hardcodedSize) {
    hardcodedSize = tempString.includes(' large ') ? 'large' : ''
  }
  tempString = tempString.replaceAll(' large ', ' size="large" ')


  //handle complex button text
  tempString = handleComplexButtonText(tempString)

  //handle a single icon
  tempString = handleSingleButtonIcon(tempString)

  //handle a conditional size
  tempString = handleConditionalSize(tempString, 'large', hardcodedSize || 'default')

  //handle normal button text
  tempString = handleButtonText(tempString)

  tempString = tempString.replace(/\s+/g, ' ')
  tempString = tempString.replace('> <', '><')

  tempString = tempString.replaceAll('<span', '\n<span')
  tempString = tempString.replaceAll('</span></AlbatrossButton>', '</span>\n</AlbatrossButton>')

  let formatted
  try{
    formatted = await prettier.format(tempString, {
      parser: 'vue',
      plugins: [htmlParser],
      htmlWhitespaceSensitivity: "ignore"
    })
  } catch (e) {
    console.error("SORRY - Couldn't Format", e)
  }

  albatrossButtonValue.value = formatted ? formatted : tempString
}

const handleButtonText = (textString) => {
  const regExString = new RegExp(`(?<=>).*?(?=</AlbatrossButton>)`)
  textString = textString.replaceAll('\n', '')
  const textBetween = regExString.exec(textString);

  if(textBetween && textBetween[0] && textBetween[0].replaceAll(' ', '').length > 0) {
    let onlyTextAndSpaces = textBetween[0].match(/^[-A-Za-z0-9().\/ ]+$/) ? true : false
    //only do button text if no special chars in the text
    if(onlyTextAndSpaces) {
      textString = textString.replace(textBetween[0], '')

      let index = textString.indexOf('>')
      let value = ` text="${textBetween[0].replaceAll(' ', '')}"`
      textString = textString.substring(0, index) + value + textString.substring(index)
    }
  }
  return textString
}

const handleComplexButtonText = (textString) => {
  let textBetween = textString.match(/([^{]+(?=}}))/g)
  if(textBetween && textBetween[0]) {
    let onlyTextAndSpaces = textBetween[0].match(/^[-A-Za-z0-9().\/ ]+$/) ? true : false
    if(onlyTextAndSpaces) {
      textString = textString.replace(textBetween[0], '')
      textString = textString.replace('{{', '')
      textString = textString.replace('}}', '')

      let index = textString.indexOf('>')
      let value = ` :text="${textBetween[0]}"`
      textString = textString.substring(0, index) + value + textString.substring(index)
    }
  }
  return textString
}

const handleSingleButtonIcon = (textString) => {
  const regExString = new RegExp(`(?<=<v-icon>).*?(?=</v-icon>)`)
  const iconBetween = regExString.exec(textString);

  //this will only have a value and refactor the icon if there is only 1 of them
  if(iconBetween && iconBetween[0]) {
    textString = textString.replace(`<v-icon>${iconBetween[0]}</v-icon>`, '')

    let index = textString.indexOf('>')
    let value = ` prepend-icon="${iconBetween[0]}"`
    textString = textString.substring(0, index) + value + textString.substring(index)
  }
  return textString
}

const handleConditionalSize = (textString, size, hardcodedSize) => {
  if(textString.includes(`:${size}`)) {
   const regExString = new RegExp(`(?<=:${size}=").*?(?=")`)
   const sizeValue = regExString.exec(textString);
    if(sizeValue && sizeValue[0]) {
      textString = textString.replace(sizeValue[0], '')
      textString = textString.replace(`:${size}=""`, '')

      let index = textString.indexOf('>')
      let value = ` \n:size="${sizeValue[0]} ? '${size}' : '${hardcodedSize}'"`
      textString = textString.substring(0, index) + value + textString.substring(index)
    }
    if(hardcodedSize !== 'default') {
      //if it was hardcoded to a specific size also then remove that
      textString = textString.replace(`size="${hardcodedSize}"`, '')
    }
  }

  return textString
}

const copyToClipboard = () => {
  navigator.clipboard.writeText(albatrossButtonValue.value);
  snackbar('SUCCESS', `Copied to clipboard`)
}
</script>
