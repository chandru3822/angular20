<template>
<v-row>
  <v-col>
    <v-row>
      <v-col>
        <h3 class="text-left">{{ group.groupName }}</h3>
      </v-col>
    </v-row>

    <v-row>
      <v-col>
        <v-card>
          <v-row
            v-for="field in group.customFieldValues" :key="field.id"
            class="text-left"
            style="border-bottom: 1px solid gray;"
            no-gutters
          >
            <v-col cols="4" class="font-weight-bold">{{ field.fieldName }}</v-col>
            <v-col cols="8">{{ field.dateValue }}</v-col>
          </v-row>
        </v-card>
      </v-col>
    </v-row>
  </v-col>
</v-row>
</template>

<script>
export default {
  name: 'ProjectFieldGroup',
  props: {
    group: Object
  }
}
</script>


<style scoped lang="scss">

</style>
