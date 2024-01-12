<template>
  <v-alert elevation="1"
           :max-width="400"
           :min-width="300"
      class="announcement-alert"
      color="white"
           :style="{'top': `${(topOffset * announcementAlert.positionOffset)}px`}"
  >
    {{announcementAlert.alertText}} {{announcementAlert.positionOffset}}
    <a>Learn More</a>
  </v-alert>
</template>

<script>
  export default {
    name: 'AnnouncementAlert',
    props: {
      // announcementAlert: {},
      //topPosition, text
    },
    data() {
      return {
        announcementAlert: {},
        show: false,
        topOffset: 30,
      }
    },
    created() {
      this.$store.subscribe((mutation, state) => {
        if (mutation.type === "SHOW_ANNOUNCEMENT") {
          this.announcementAlert = state.app.announcement
          console.log('aaa',this.announcementAlert)
          this.show = true
        }
      });
    },
  }
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
.announcement-alert {
  position: absolute;
  right: 50px;
}
</style>
