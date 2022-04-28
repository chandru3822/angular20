<template>
  <div class="panel">
    <slot></slot>
  </div>
</template>
<script>
export default {
  name: 'Panel',

}
</script>
<style lang="scss" scoped>
.panel {
  background: #fff;
  user-select: none;
  display: flex;
  flex-direction:column;
  flex: 1;
  box-shadow: -2px -3px 5px #ccc;
  padding: 20px;
}
</style>
