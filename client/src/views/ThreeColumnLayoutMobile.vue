
<script setup>
/*
*@name ThreeColumnLayoutMobile
*@author jkburnett
*@date
*
*@description
* mobile layout for screens with three columns, such as project, contact, orgs, etc
*
* @props
* menuItems - Array of Strings to be used as the side menu title; should be in the order in which they should appear,
* and each object should contain the following properties
*   pageName: String
*   subMenuSlot: Boolean //(optional -defaults to false) if true, makes the list item into an expansion panel with dynamic slots available for its children
*   customPath: (optional)String representing the path
*   any other data needed for the callback function
*
* headerHeight: String, optional
* headerColor: String, optional
* viewChangeCallback: callback function when menu item is selected
* subMenuSelectedView: Object, optional, allows us to close the menu when using a submenu and the route doesn't change


*/
import {ref, defineProps, defineEmits, onMounted, watch} from 'vue'
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton";

const props = defineProps({
  menuItems: Array, //@required
  headerHeight: String, //@optional
  headerColor: String, //@optional
  viewChangeCallback: Function, //@required,
  subMenuSelectedView: Object //@optional, allows us to close the menu when using a submenu and the route doesn't change

})
const emit = defineEmits(['selectMenuItem'])

const showMenu=ref(false)
const toggleMenu = (forceClose) => {
    if(forceClose){
      showMenu.value = false
    } else {
      showMenu.value = !showMenu.value
    }
  }
  watch(
      () => props.subMenuSelectedView,
      () => {
        // console.log('watcher')
        toggleMenu(true)
        //fires only when subMenuSelectedView is replaced
        //allows us to close the menu when using a submenu and the route doesn't change
      })

  const selectedViewId=ref(0)
  const routerView=ref(false)
const chooseSelectedView = (view, id) => {
  selectedViewId.value = id
  props.viewChangeCallback(view, true)
}

</script>
<template>
  <v-container class="pa-0" id="three-column-container">
    <v-navigation-drawer v-model="showMenu" absolute temporary clipped>
      <v-list>
        <v-list-item v-for="(item, index) in menuItems" :key="index" class="px-0" :class="{'my-1': !item.subMenuSlot, 'active': item.customPath && $route.path.includes(item.customPath)}">
          <v-list-item-title class="mx-6 label-large" v-if="!item.subMenuSlot" @click="chooseSelectedView(item, index)">{{ item.pageName }}</v-list-item-title>
          <slot :name="`subMenu_${index}`"/>
        </v-list-item>
      <v-list-item class="px-0 my-1" style="height: 100px">
<!--this is an empty list item to hopefully fix the fact that stupid iphones cover the bottom of the webpage and you can't scroll down to see Project Admin-->
          <v-list-item-title class="mx-6 label-large"></v-list-item-title>
        </v-list-item>
      </v-list>
    </v-navigation-drawer>
  <v-row>
    <v-toolbar id="three-column-header" flat :height="headerHeight" :color="headerColor ? headerColor : 'grey lighten-2'">
    <AlbatrossButton size="small" variant="text" prepend-icon="mdi-menu" @click="toggleMenu(false)"/>
    <slot name="header-contents">
    </slot>
    </v-toolbar>
  </v-row>
  <v-row class="mobile-background height-one-hunned">
    <v-col class=" py-0 main-column-container">
    <slot name="main-column"/>
    </v-col>
  </v-row>
  </v-container>
</template>

<style lang="scss">
#three-column-container > aside{
  z-index: 12; //to cover the search bar on the Notes page,
  // which has a z-index of 10 so that the filter dropdown covers cards in the notes/activites list
}
</style>
<style scoped lang="scss">
#three-column-container {
  width: 100%;
  height: 100%;
  max-height: 100% !important;
  padding: 0 !important;
  overflow: hidden;
  z-index: 12;
}

#three-column-container > aside{
  height: 100% !important;
}

.main-column-container {
  height: 80%;
}

.three-column-header {
  height: 64px;
  background-color: var(--v-grey-lighten2) !important;
}

.active {
  background-color: var(--v-primary-lighten9);
}

.white-bg {
  background-color: #fff;
}
</style>
<style lang="scss">

#three-column-header {
  height: fit-content !important;

  div.v-toolbar__content {
    align-items: flex-start;
    height: fit-content !important;
    padding-top: 16px;
    padding-bottom: 12px;
  }
}
</style>
