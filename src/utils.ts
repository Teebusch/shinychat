export const formatTime = function(timestamp: string): string{
  let date = new Date(timestamp);
  return(date.toLocaleTimeString());
}