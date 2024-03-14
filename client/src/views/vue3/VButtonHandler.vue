<template>
  <v-main>
    <v-container>

      <v-row>
        <v-col cols="6">
          <h3 class="mb-5">Paste the v-btn code here</h3>
          <v-textarea v-model="vBtnValue" outlined @input="vBtnInput()"
                      ref="inputField" auto-grow
                      label="V-BTN Value" />
          <AlbatrossButton
              :disabled="!vBtnValue"
              @click="processBtn" text="Submit"></AlbatrossButton>
          <AlbatrossButton class="ml-4" variant="text"
              @click="doClear" text="Clear"></AlbatrossButton>
        </v-col>
        <v-col cols="6" class="mt-9">
          <v-checkbox dense hide-details label="Auto copy to clipboard?" v-model="autoCopyToClipboard"></v-checkbox>
          <v-checkbox dense hide-details label="Reset and Refocus on Paste?" v-model="resetFieldsOnPaste"></v-checkbox>
          <div>
            When doing a lot of buttons without irregular behavior this will copy to clipboard, reset the fields, and re-focus for fast & easy copy paste.
          </div>
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
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue"
import * as prettier from 'prettier'
import htmlParser from 'prettier/parser-html'

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const router = vueInstance.$router
const snackbar = vueInstance.$snackbar

const vBtnValue = ref(null)
const albatrossButtonValue = ref(null)
const inputField = ref(null)
const autoCopyToClipboard = ref(true)
const resetFieldsOnPaste = ref(true)

//for testing
// vBtnValue.value = '<v-btn\n' +
//     '                                text\n' +
//     '                                class="d-inline-block"\n' +
//     '                                v-bind="attrs"\n' +
//     '                                v-on="on"\n' +
//     '                              >\n' +
//     '                                <v-icon>\n' +
//     '                                  mdi-information\n' +
//     '                                </v-icon>\n' +
//     '                              </v-btn>'

onMounted(() => {
  // processBtn()
})

const doClear = () => {
  vBtnValue.value = null
  albatrossButtonValue.value = null
  inputField.value.focus()
}

const processBtn = async () => {
  let tempString = vBtnValue.value
  tempString = tempString.replaceAll('v-btn', 'AlbatrossButton')
  tempString = tempString.replaceAll(' dark ', ' ')
  tempString = tempString.replaceAll(' dark\n', ' ')
  tempString = tempString.replaceAll(' text ', ' variant="text" ')
  tempString = tempString.replaceAll(' text\n', ' variant="text" ')
  tempString = tempString.replaceAll(' outlined ', ' variant="outlined" ')
  tempString = tempString.replaceAll(' outlined\n ', ' variant="outlined" ')
  tempString = tempString.replaceAll('white--text', '')
  tempString = tempString.replaceAll('style', 'html-style')
  tempString = tempString.replaceAll('type', 'btn-type')
  tempString = tempString.replaceAll(' x-small ', ' size="x-small" ')
  let hardcodedSize = tempString.includes(' small ') ? 'small' : ''
  tempString = tempString.replaceAll(' small ', ' size="small" ')
  if(!hardcodedSize) {
    hardcodedSize = tempString.includes(' large ') ? 'large' : ''
  }
  tempString = tempString.replaceAll(' large ', ' size="large" ')
  tempString = tempString.replaceAll('v-on="on"', ':activation-handler="on"')
  tempString = tempString.replaceAll('<v-icon', '\n<v-icon')
  tempString = tempString.replaceAll('class=""', '')

  //handle no color
  //if there is no color then it needs to be set to 'unset' as we default to color = primary since that is the most commonly used
  tempString = handleNoColor(tempString)

  //handle exactly 2 icons
  tempString = handleTwoIcons(tempString)

  //handle complex button text
  tempString = handleComplexButtonText(tempString)

  //handle a single icon
  tempString = handleSingleButtonTag(tempString, 'v-icon', 'prepend-icon')

  //handle a single span
  tempString = handleSingleButtonTag(tempString, 'span', 'text')

  //handle a conditional size
  tempString = handleConditionalSize(tempString, 'large', hardcodedSize || 'default')

  //handle normal button text
  tempString = handleButtonText(tempString)


  tempString = tempString.replace(/\s+/g, ' ')
  tempString = tempString.replace('> <', '><')

  //todo: make cool matcher for multiples but i dont really care right now
  tempString = tempString.replaceAll('<span', '\n<span')
  tempString = tempString.replaceAll('</span></AlbatrossButton>', '</span>\n</AlbatrossButton>')

  tempString = tempString.replaceAll('<v-icon', '\n<v-icon')
  tempString = tempString.replaceAll('</v-icon></AlbatrossButton>', '</v-icon>\n</AlbatrossButton>')
  tempString = tempString.replaceAll('</v-icon> </AlbatrossButton>', '</v-icon>\n</AlbatrossButton>')

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

  let finalValue = formatted ? formatted : tempString
  finalValue = finalValue.replace('</AlbatrossButton>\n', '</AlbatrossButton>')
  albatrossButtonValue.value = finalValue

  if(autoCopyToClipboard.value) {
    copyToClipboard()
  }
  if(resetFieldsOnPaste.value) {
    doClear()
  }
}

const vBtnInput = () => {
  albatrossButtonValue.value = null
  if(resetFieldsOnPaste.value) {
    processBtn()
    // doClear()
  }
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
      let value = ` text="${textBetween[0].trim()}"`
      textString = textString.substring(0, index) + value + textString.substring(index)
    }
  }
  return textString
}

const handleNoColor = (textString) => {
  let indexOfColor = textString.indexOf('color')
  if(indexOfColor === -1) {
    textString = textString.replace('>', ` color="unset">`)
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

const handleSingleButtonTag = (textString, htmlTag, newProperty) => {
  let endHtmlTag = `</${htmlTag}>`
  let startHtmlTag = `<${htmlTag}`
  const regExString = new RegExp(`(?<=>).*?(?=${endHtmlTag})`)
  let iconBetween = regExString.exec(textString);

  //this will only have a value and refactor the icon if there is only 1 of them
  if(iconBetween && iconBetween[0]) {
    let firstIndex = textString.indexOf(`${startHtmlTag}`)
    let secondIndex = textString.indexOf(`${endHtmlTag}`)
    let stringToReplace = textString.substring(firstIndex, secondIndex + 9)
    textString = textString.replace(stringToReplace, '')

    //"> to try and avoid greater than symbol in v-if or disabled prop
    if(newProperty === 'text') {
      let indexOfCurly = textString.indexOf('{')
      if(indexOfCurly !== -1) {
        newProperty = ':' + newProperty
        iconBetween[0] = iconBetween[0].replaceAll('{', '')
        iconBetween[0] = iconBetween[0].replaceAll('}', '')
      }
    }
    let index = textString.indexOf('">')
    let value = `" ${newProperty}="${iconBetween[0]}"`
    textString = textString.substring(0, index) + value + textString.substring(index + 1)
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

const handleTwoIcons = (textString) => {
  //specifically only handle exactly two icons
  let vIf
  let firstIcon, secondIcon
  let stringToRemove, stringToRemove2

    //get the v-if (have to get the text in the icon first in case the btn itself has a v-if
    const regExString1 = new RegExp(`(?<=<v-icon).*?(?=</v-icon>)`)
    const regExString2 = new RegExp(`(?<=v-if=").*?(?=")`)
    const myIfWrapper = regExString1.exec(textString);
    if(myIfWrapper && myIfWrapper[0]) {
      const myIfValue = regExString2.exec(myIfWrapper[0]);
      if(myIfValue && myIfValue[0]) {
        vIf = myIfValue[0]
      }
    }
    //check if there are only 2
    if((textString.match(/<v-icon/g))?.length === 2) {
      //get the first v-icon then remove it
      let stringToTest = String(textString)
      const regExString3 = new RegExp(`(?<=>).*?(?=</v-icon>)`)
      const iconValue = regExString3.exec(stringToTest);
      if(iconValue && iconValue[0]) {
        firstIcon = iconValue[0]
        let firstIndex = stringToTest.indexOf('<v-icon')
        let secondIndex = stringToTest.indexOf('</v-icon>')
        stringToRemove = stringToTest.substring(firstIndex, secondIndex + 9)
        stringToTest = stringToTest.replace(stringToRemove, '')

        const regExString4 = new RegExp(`(?<=>).*?(?=</v-icon>)`)
        const iconValue2 = regExString4.exec(stringToTest);
        if(iconValue2 && iconValue2[0]) {
          secondIcon = iconValue2[0]
          let firstIndex2 = stringToTest.indexOf('<v-icon')
          let secondIndex2 = stringToTest.indexOf('</v-icon>')
          stringToRemove2 = stringToTest.substring(firstIndex2, secondIndex2 + 9)

        }
      }
    }


    if(vIf && firstIcon && secondIcon) {
      textString = textString.replace(stringToRemove, '')
      textString = textString.replace(stringToRemove2, '')
      textString = textString.replace('>', ` :prepend-icon="${vIf} ? '${firstIcon}' : '${secondIcon}'">`)
    }

  return textString
}

const copyToClipboard = () => {
  navigator.clipboard.writeText(albatrossButtonValue.value);
  snackbar('SUCCESS', `Copied to clipboard`)
}
</script>
