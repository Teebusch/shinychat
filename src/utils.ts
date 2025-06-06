export const formatTime = function(time: string | Date): string {
  if (typeof time === 'string') {
    time = new Date(time);
  }
  return(time.toLocaleTimeString());
}