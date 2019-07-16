<template>
  <v-app id="app">
    <router-view/>
  </v-app>
</template>

<style lang="scss">
/*
 * OVERRIDES FOR VUETIFY THEMES
*/
.theme--light,
.theme--light.application,
.theme--light.application .text--primary,
.theme--light.v-list-item:not(.v-list-item--active):not(.v-list-item--disabled),
.theme--light.v-input:not(.v-input--is-disabled) input,
.theme--light.v-select .v-select__selections {
  color: var(--v-primaryText-base) !important;
  /*color: #1F3C73 !important;*/
}
/*
 * not sure what to do about this. this makes the date time picker look way nicer and doesn't
 * seem to affect anything else so far.  will have to figure out a solution later if it does
 */
body {
  font-family: Verdana, 'Arial', sans-serif;
  background: #f8f8f8;
}

#app {
  font-family: 'Lato', sans-serif;
  letter-spacing: .4px;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  background-color: var(--v-secondary-base);
  min-height: 100vh;
}
.app-button{
  padding: 0 5px;
  border-radius: 3px;
  text-transform: capitalize;
  height: 45px !important;
}
.router-container{
  justify-content: center;
  max-width: 100vw;
  overflow: auto;
}
label[for="adminOriginatorSelect"] {
  color: var(--v-secondary-base) !important;
}
.green-text{
  color: #73d697 !important;
}
.red-text{
  color: #ee6f6a !important;
}
.grab {
  cursor: grab;
  &:active {
    cursor: grabbing;
  }
}
.table-title-row{
  height: 70px;
  line-height: 70px;
  background-color: #ffffff;
  color: rgba(0,0,0,0.87);
  border-top-left-radius: 2px;
  border-top-right-radius: 2px;
  border-collapse: collapse;
  border-spacing: 0;
  border-bottom: solid 2px var(--v-primary-base);
  width: 100%;
  max-width: 100%;
  padding-left: 10px;
  text-align: left;
  vertical-align: middle;
}
.table-header-with-title .v-datatable{
  border-top-left-radius: 0;
  border-top-right-radius: 0;
}
.table-title{
  font-size: 24px;
  vertical-align: middle;
  margin-left: 10px;
}
.flex-display {
  display: flex;
}
.page-header{
  text-align: left;
  font-size: 30px;
  font-weight: 600;
}
.page-subheader{
  text-align: left;
  font-size: 30px;
  font-weight: 600;
}

.fix-opacity {
  opacity: 100 !important;
}

.shaded-row{
  background-color: var(--v-rowShadeCustom-base) !important;
  /*background-color: #EAEAF4 !important;*/
}

.clickable {
  cursor: pointer
}
.no-display {
  display: none !important;
}
.centered {
  text-align: center;
}
.error-text {
  color: var(--v-error-base) !important;
}

.one-hunned {
  width: 100%;
}
.bordered {
  border: solid 1px var(--v-primary-base);
  border-color: #000 !important;
}
.overflow-auto {
  overflow: auto;
}
.relative {
  position: relative;
}

.br-5 {
  border-radius: 5px;
}

.br-10 {
  border-radius: 10px;
}

@media (min-width: 769px) {
  .router-container{
    display: flex;
  }
  .router-view{
    /* @joe - do we even need this?  lets just use the full screen till they complain. i hate the white space on the sides */
    /*margin-left: 107px !important;*/
    /*margin-right: 107px !important;*/
  }
  .page-header{
    font-size: 40px;
  }
  .page-subheader{
    padding-left: 40px;
  }
  .app-button{
    padding: 0 16px;
    border-radius: 3px;
    height: 45px !important;
    margin-right: 10px !important;
  }
}
</style>
