export function generateUUID(): string {
  let seed = Date.now();
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c: string) => {
    seed = (seed * 9301 + 49297) % 233280;
    const r = (seed / 233280.0) * 16 | 0;
    const v = c === 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
}
