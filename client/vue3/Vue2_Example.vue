<template>
  <v-container class="mt-4">
    <v-card class="px-3">
      <SpinnerInline/>
      {{ myDynamicObject }}
      {{ myStaticObject }}
    </v-card>

  </v-container>
</template>

<script>
import SpinnerInline from '@/components/SpinnerInline'

export default {
  name: 'NewContact',  //not required
  components: {
    SpinnerInline,
  },
  props: {
    pageName: String
  },
  watch: {
    watchedValue: {
      //do stuff
    }
  },
  computed: {
    canAdd() {
      return this.myDynamicBoolean
    }
  },
  data () {
    return {
      myDynamicObject: {},
      myStaticObject: {},
      myDynamicBoolean: false,
      projectId: this.$route.params.projectId,
      userCanAdd: this.$store.getters.userHasFeatureAccessLevel('PROJECTS', 'ADD'),
    }
  },
  beforeRouteLeave(to, from, next) {
    //do stuff
    next()
  },
  beforeRouteEnter(to, from, next) {
    next((vm) => {
      //do stuff
    });
  },
  created () {
    this.myMethod()
  },
  methods: {
    async myMethod () {
      //set a dynamic value
      this.myDynamicObject = { id: 1 }
      //set a static value
      this.myStaticObject = { id: 1 }

      await this.$router.push('/login')
      this.$emit('clearSearch')
    }
  }

}
</script>

<style lang="scss">
  #title-container ::v-deep .v-toolbar__content {
    width: 100%;
  }
</style>

<style scoped lang="scss">

</style>
