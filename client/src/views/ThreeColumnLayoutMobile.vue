
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

*/
import { ref, defineProps } from 'vue'

const props = defineProps({
  menuItems: Array, //@required
  headerHeight: String, //@optional
  headerColor: String, //@optional
})

const showMenu=ref(false)
const toggleMenu = () => {
  console.log(props.menuItems)
    showMenu.value = !showMenu.value
  }
</script>
<template>
  <v-container class="pa-0" id="three-column-container">
    <v-navigation-drawer v-model="showMenu" absolute temporary clipped>
      <v-list>
        <v-list-item v-for="(item, index) in menuItems" :key="index" class="px-0">
          <v-list-item-title class="mx-6 label-large" v-if="!item.subMenuSlot">{{ item.itemName }}</v-list-item-title>
          <slot :name="`subMenu_${index}`"/>
        </v-list-item>
      </v-list>
    </v-navigation-drawer>
  <v-row>
    <v-toolbar flat :height="headerHeight" :color="headerColor ? headerColor : 'grey lighten-2'">
    <v-btn small text color="primary" @click="toggleMenu" class="mt-1">
      <v-icon>mdi-menu</v-icon>
    </v-btn>
    <slot name="header-contents">
    </slot>
    </v-toolbar>
  </v-row>
  <v-row>
    <v-col class="auto-overflow">
    <slot name="main-column"/>
    </v-col>
  </v-row>
  </v-container>
</template>

<style scoped lang="scss">
#three-column-container {
  width: 100%;
  height: 100%;
  max-height: 100% !important;
  padding: 0 !important;
  overflow: hidden;
}
#menu-container {
  width: 100%;
  height: 100%;
}

.three-column-header {
  height: 64px;
  background-color: var(--v-grey-lighten2) !important;
}

.white-bg {
  background-color: #fff;
}
</style>
